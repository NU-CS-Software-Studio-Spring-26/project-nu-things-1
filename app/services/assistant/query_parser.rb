# frozen_string_literal: true

module Assistant
  class QueryParser
    BOARDS = %w[lost found rentals marketplace].freeze

    SYSTEM_PROMPT = <<~PROMPT.squish
      You parse user messages for Purple Post, a Northwestern University campus board with four listing types:
      lost (open missing-item reports), found (unclaimed found items), rentals (available gear to borrow),
      and marketplace (active buy/sell listings).
      Valid categories: #{ListingCategories::VALUES.join(", ")}.
      Return JSON only.
    PROMPT

    def self.call(message:, history: [], client: GeminiClient.new)
      new(message: message, history: history, client: client).call
    end

    def initialize(message:, history:, client:)
      @message = message.to_s.strip
      @history = history
      @client = client
    end

    def call
      raw = @client.generate_json(system: SYSTEM_PROMPT, prompt: build_prompt)
      normalize(raw)
    rescue GeminiClient::Error
      fallback
    end

    private

    def build_prompt
      <<~PROMPT
        Recent conversation:
        #{format_history}

        Latest user message:
        #{@message}

        Return JSON with this shape:
        {
          "boards": ["lost", "found", "rentals", "marketplace"],
          "search_terms": ["keyword", "phrases"],
          "category": null,
          "marketplace_type": null,
          "intent_summary": "short plain-English summary of what the user wants"
        }

        Rules:
        - "boards" must use only: lost, found, rentals, marketplace.
        - If the user lost something, search found first, then lost.
        - If the user found something, search lost first, then found.
        - If the user wants to borrow or rent, search rentals.
        - If the user wants to buy or sell, search marketplace.
        - "category" must be null or one of the valid categories exactly.
        - "marketplace_type" must be null, "for_sale", or "wanted".
        - "search_terms" should be 1-6 useful keywords; omit filler words.
      PROMPT
    end

    def format_history
      lines = @history.last(6).filter_map do |entry|
        role = entry["role"] || entry[:role]
        body = entry["body"] || entry[:body]
        next if body.blank?

        label = role == "user" ? "User" : "Assistant"
        "#{label}: #{body.to_s.tr("\n", " ")}"
      end
      lines.presence&.join("\n") || "(none)"
    end

    def normalize(raw)
      boards = Array(raw["boards"]).map(&:to_s).map(&:downcase) & BOARDS
      boards = default_boards if boards.empty?

      category = raw["category"].to_s.presence
      category = nil unless ListingCategories::VALUES.include?(category)

      marketplace_type = raw["marketplace_type"].to_s.presence
      marketplace_type = nil unless MarketplaceListing::LISTING_TYPES.include?(marketplace_type)

      {
        boards: boards,
        search_terms: normalize_terms(raw["search_terms"]),
        category: category,
        marketplace_type: marketplace_type,
        intent_summary: raw["intent_summary"].to_s.presence || @message
      }
    end

    def normalize_terms(terms)
      list = Array(terms).map { |t| t.to_s.strip.downcase }.reject(&:blank?)
      list = @message.downcase.split(/\s+/).first(6) if list.empty?
      list.uniq
    end

    def default_boards
      %w[found lost rentals marketplace]
    end

    def fallback
      boards = if @message.match?(/\b(rent|borrow|loan)\b/i)
        %w[rentals]
      elsif @message.match?(/\b(buy|sell|price|marketplace)\b/i)
        %w[marketplace]
      elsif @message.match?(/\b(found|picked up)\b/i)
        %w[lost found]
      else
        %w[found lost rentals marketplace]
      end

      {
        boards: boards,
        search_terms: @message.downcase.split(/\s+/).reject { |w| w.length < 3 }.first(6),
        category: nil,
        marketplace_type: nil,
        intent_summary: @message
      }
    end
  end
end
