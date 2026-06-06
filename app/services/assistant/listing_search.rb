# frozen_string_literal: true

module Assistant
  class ListingSearch
    Candidate = Data.define(
      :key, :type, :id, :title, :description, :category, :location, :color, :brand, :board_label,
      :extra
    )

    BOARD_CONFIG = {
      "lost" => {
        model: LostItem,
        board_label: "Lost",
        scope: ->(relation) { relation.where(status: "open") },
        location: :location_lost
      },
      "found" => {
        model: FoundItem,
        board_label: "Found",
        scope: ->(relation) { relation.where(status: "unclaimed") },
        location: :location_found
      },
      "rentals" => {
        model: RentalItem,
        board_label: "Rental",
        scope: ->(relation) { relation.where(status: "available") },
        location: :location
      },
      "marketplace" => {
        model: MarketplaceListing,
        board_label: "Marketplace",
        scope: ->(relation) { relation.where(status: "active") },
        location: :location
      }
    }.freeze

    def self.call(parsed:, limit: 20)
      new(parsed: parsed, limit: limit).call
    end

    def initialize(parsed:, limit:)
      @parsed = parsed
      @limit = limit
    end

    def call
      candidates = search_parsed(@parsed, apply_category: true)
      return candidates if candidates.any?

      candidates = search_parsed(@parsed.merge(category: nil), apply_category: false)
      return candidates if candidates.any?

      keyword = SearchTerms.best_keyword(@parsed[:search_terms], fallback_text: @parsed[:intent_summary])
      return [] if keyword.blank?

      search_parsed(
        @parsed.merge(
          boards: %w[rentals marketplace found lost],
          search_terms: [ keyword ],
          category: nil,
          marketplace_type: nil
        ),
        apply_category: false
      )
    end

    private

    def search_parsed(parsed, apply_category:)
      candidates = []
      boards = Array(parsed[:boards]).presence || %w[rentals marketplace found lost]
      per_board = [ (@limit.to_f / boards.size).ceil, 5 ].max

      boards.each do |board_key|
        break if candidates.size >= @limit

        remaining = @limit - candidates.size
        board_candidates = search_board(
          board_key,
          parsed: parsed,
          apply_category: apply_category,
          limit: [ per_board, remaining ].min
        )
        candidates.concat(board_candidates)
      end

      candidates.first(@limit)
    end

    def search_board(board_key, parsed:, apply_category:, limit:)
      config = BOARD_CONFIG[board_key]
      return [] unless config

      relation = config[:model].order(created_at: :desc)
      relation = config[:scope].call(relation)
      relation = filter_category(relation, config[:model], parsed, apply_category)
      relation = filter_marketplace_type(relation, board_key, parsed)
      relation = filter_search(relation, parsed[:search_terms], parsed[:intent_summary])

      relation.limit(limit).map { |record| build_candidate(record, config) }
    end

    def filter_category(relation, model, parsed, apply_category)
      return relation unless apply_category

      category = parsed[:category]
      return relation if category.blank?
      return relation unless model::CATEGORIES.include?(category)

      relation.where(category: category)
    end

    def filter_marketplace_type(relation, board_key, parsed)
      return relation unless board_key == "marketplace"

      listing_type = parsed[:marketplace_type]
      return relation if listing_type.blank?

      relation.where(listing_type: listing_type)
    end

    def filter_search(relation, terms, fallback_text)
      keywords = SearchTerms.extract(terms, fallback_text: fallback_text)
      return relation if keywords.empty?

      clauses = keywords.flat_map do
        [ "LOWER(title) LIKE LOWER(?)", "LOWER(description) LIKE LOWER(?)" ]
      end
      values = keywords.flat_map { |keyword| [ like(keyword), like(keyword) ] }

      relation.where(clauses.join(" OR "), *values)
    end

    def like(keyword)
      "%#{ActiveRecord::Base.sanitize_sql_like(keyword)}%"
    end

    def build_candidate(record, config)
      type = record.model_name.singular
      location_attr = config[:location]
      extra = {}

      if record.is_a?(MarketplaceListing)
        extra["listing_type"] = record.listing_type
        extra["price"] = record.price
        extra["condition"] = record.condition
      elsif record.is_a?(RentalItem)
        extra["rental_price"] = record.rental_price
        extra["rental_period"] = record.rental_period
      end

      Candidate.new(
        key: "#{type}:#{record.id}",
        type: type,
        id: record.id,
        title: record.title.to_s,
        description: record.description.to_s.truncate(400),
        category: record.respond_to?(:category_label) ? record.category_label : record.category.to_s,
        location: record.public_send(location_attr).to_s,
        color: record.try(:color).to_s,
        brand: record.try(:brand).to_s,
        board_label: config[:board_label],
        extra: extra
      )
    end
  end
end
