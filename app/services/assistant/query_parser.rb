# frozen_string_literal: true

module Assistant
  class QueryParser
    BOARDS = %w[lost found rentals marketplace].freeze

    SYSTEM_PROMPT = <<~PROMPT.squish
      You parse user messages for Purple Post, a Northwestern University campus board with four listing types:
      lost (open missing-item reports), found (unclaimed found items), rentals (available gear to borrow),
      and marketplace (active buy/sell listings).
      Valid categories: #{ListingCategories::VALUES.join(", ")}.
      Return JSON only. search_terms must be concrete item nouns only — never filler words.
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
          "boards": ["rentals", "marketplace"],
          "search_terms": ["tent"],
          "category": null,
          "marketplace_type": null,
          "intent_summary": "user wants a tent"
        }

        Rules:
        - "boards" must use only: lost, found, rentals, marketplace.
        - If the user lost something, use ["found", "lost"].
        - If the user found something, use ["lost", "found"].
        - If the user wants to borrow, rent, or use something temporarily, use ["rentals"] and often ["marketplace"] too.
        - If the user wants to buy or sell, use ["marketplace", "rentals"].
        - If intent is unclear but they describe an item, search ["rentals", "marketplace", "found", "lost"].
        - "search_terms" must be 1-4 concrete nouns/adjectives for the ITEM ONLY (e.g. "tent", "backpack", "econ textbook").
          NEVER include filler words like: looking, find, for, buy, want, need, am, the, a.
        - "category" must be null unless the user clearly names a valid category.
        - "marketplace_type" must be null, "for_sale", or "wanted".

        Examples:
        - "I am looking for a tent" -> boards: ["rentals", "marketplace"], search_terms: ["tent"]
        - "Buy tent" -> boards: ["marketplace", "rentals"], search_terms: ["tent"]
        - "I lost my black backpack near SPAC" -> boards: ["found", "lost"], search_terms: ["backpack", "black"]
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
      boards = infer_boards if boards.empty?

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
      extracted = SearchTerms.extract(terms, fallback_text: @message)
      extracted.presence || SearchTerms.extract([ @message ], fallback_text: @message)
    end

    def infer_boards
      fallback[:boards]
    end

    def fallback
      boards = if @message.match?(/\b(lost|missing|misplaced)\b/i)
        %w[found lost]
      elsif @message.match?(/\b(found|picked up)\b/i)
        %w[lost found]
      elsif @message.match?(/\b(rent|borrow|loan|hire)\b/i)
        %w[rentals marketplace]
      elsif @message.match?(/\b(buy|sell|purchase|marketplace)\b/i)
        %w[marketplace rentals]
      else
        %w[rentals marketplace found lost]
      end

      {
        boards: boards,
        search_terms: SearchTerms.extract([ @message ], fallback_text: @message),
        category: nil,
        marketplace_type: nil,
        intent_summary: @message
      }
    end
  end
end
