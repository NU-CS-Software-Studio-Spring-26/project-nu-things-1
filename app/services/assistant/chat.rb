# frozen_string_literal: true

module Assistant
  class Chat
    class Error < StandardError; end

    Result = Data.define(:reply, :listings)

    ListingResult = Data.define(
      :key, :type, :id, :title, :board_label, :reason, :path, :category, :location
    )

    def self.process!(message:, history: [])
      new(message: message, history: history).process!
    end

    def initialize(message:, history:)
      @message = message.to_s.strip
      @history = history
    end

    def process!
      raise Error, "Message can't be blank." if @message.blank?

      parsed = QueryParser.call(message: @message, history: @history)
      candidates = ListingSearch.call(parsed: parsed, limit: 20)

      if candidates.empty?
        return Result.new(
          reply: no_results_reply(parsed),
          listings: []
        )
      end

      reranked = Reranker.call(
        message: @message,
        parsed: parsed,
        candidates: candidates,
        history: @history
      )

      listings = build_listings(reranked[:matches], candidates)
      Result.new(reply: reranked[:reply], listings: listings)
    end

    private

    def build_listings(matches, candidates)
      by_key = candidates.index_by(&:key)

      matches.filter_map do |match|
        candidate = by_key[match[:key]]
        next unless candidate

        ListingResult.new(
          key: candidate.key,
          type: candidate.type,
          id: candidate.id,
          title: candidate.title,
          board_label: candidate.board_label,
          reason: match[:reason],
          path: listing_path_for(candidate),
          category: candidate.category,
          location: candidate.location
        )
      end
    end

    def listing_path_for(candidate)
      record = candidate.type.classify.constantize.find_by(id: candidate.id)
      return "#" unless record

      Assistant::Routes.path_for(record)
    end

    def no_results_reply(parsed)
      terms = Array(parsed[:search_terms]).join(" ")
      if terms.present?
        "I didn't find listings matching \"#{terms}\" on Purple Post. Try broader keywords or check another board."
      else
        "I didn't find matching listings. Try describing the item, whether you lost it, found it, want to rent it, or buy/sell it."
      end
    end
  end
end
