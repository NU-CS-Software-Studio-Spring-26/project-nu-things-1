# frozen_string_literal: true

module Assistant
  class Chat
    class Error < StandardError; end

    Result = Data.define(:reply, :listings)

    ListingResult = Data.define(
      :key, :type, :id, :title, :board_label, :reason, :path, :category, :location
    )

    def self.process!(message:, history: [], viewer: nil)
      new(message: message, history: history, viewer: viewer).process!
    end

    def initialize(message:, history:, viewer: nil)
      @message = message.to_s.strip
      @history = history
      @viewer = viewer
    end

    def process!
      raise Error, "Message can't be blank." if @message.blank?

      parsed = QueryParser.call(message: @message, history: @history)
      candidates = ListingSearch.call(parsed: parsed, limit: 20, viewer: @viewer)

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
      keywords = SearchTerms.extract(parsed[:search_terms], fallback_text: parsed[:intent_summary])
      if keywords.any?
        "I didn't find listings for #{keywords.join(', ')} on Purple Post. Try a shorter keyword (e.g. just \"tent\") or browse Rentals and Marketplace."
      else
        "I didn't find matching listings. Try naming the item in a few words — e.g. \"tent\", \"backpack\", or \"econ textbook\"."
      end
    end
  end
end
