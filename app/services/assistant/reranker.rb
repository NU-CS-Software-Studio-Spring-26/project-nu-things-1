# frozen_string_literal: true

module Assistant
  class Reranker
    RESULT_LIMIT = 5

    SYSTEM_PROMPT = <<~PROMPT.squish
      You rank Purple Post campus listings for relevance to a user's search.
      Only choose listing keys from the provided list. Return JSON only.
    PROMPT

    def self.call(message:, parsed:, candidates:, history: [], client: GeminiClient.new)
      new(message: message, parsed: parsed, candidates: candidates, history: history, client: client).call
    end

    def initialize(message:, parsed:, candidates:, history:, client:)
      @message = message
      @parsed = parsed
      @candidates = candidates
      @history = history
      @client = client
    end

    def call
      return empty_result if @candidates.empty?

      raw = @client.generate_json(system: SYSTEM_PROMPT, prompt: build_prompt)
      normalize(raw)
    rescue GeminiClient::Error
      fallback
    end

    private

    def build_prompt
      listings_json = @candidates.map { |candidate| candidate_to_json(candidate) }

      <<~PROMPT
        User intent: #{@parsed[:intent_summary]}
        Latest user message: #{@message}

        Recent conversation:
        #{format_history}

        Candidate listings (JSON):
        #{JSON.pretty_generate(listings_json)}

        Return JSON:
        {
          "reply": "2-4 sentence friendly message for the user",
          "matches": [
            { "key": "found_item:1", "reason": "short reason under 120 characters" }
          ]
        }

        Rules:
        - Include at most #{RESULT_LIMIT} matches, ordered best-first.
        - Only use keys from the candidate list.
        - If nothing is relevant, return an empty matches array and explain in reply.
        - Mention Northwestern campus context when helpful.
        - Do not invent listings.
      PROMPT
    end

    def candidate_to_json(candidate)
      {
        key: candidate.key,
        board: candidate.board_label,
        title: candidate.title,
        description: candidate.description,
        category: candidate.category,
        location: candidate.location,
        color: candidate.color,
        brand: candidate.brand
      }.merge(candidate.extra)
    end

    def format_history
      lines = @history.last(4).filter_map do |entry|
        role = entry["role"] || entry[:role]
        body = entry["body"] || entry[:body]
        next if body.blank?

        label = role == "user" ? "User" : "Assistant"
        "#{label}: #{body.to_s.tr("\n", " ")}"
      end
      lines.presence&.join("\n") || "(none)"
    end

    def normalize(raw)
      allowed_keys = @candidates.map(&:key)
      matches = Array(raw["matches"]).filter_map do |match|
        key = match["key"].to_s
        next unless allowed_keys.include?(key)

        {
          key: key,
          reason: match["reason"].to_s.truncate(120).presence || "May match your search."
        }
      end.uniq { |m| m[:key] }.first(RESULT_LIMIT)

      reply = raw["reply"].to_s.strip
      reply = default_reply(matches) if reply.blank?

      { reply: reply, matches: matches }
    end

    def fallback
      matches = @candidates.first(RESULT_LIMIT).map do |candidate|
        { key: candidate.key, reason: "Keyword match on #{candidate.board_label.downcase} board." }
      end

      { reply: default_reply(matches), matches: matches }
    end

    def default_reply(matches)
      if matches.empty?
        "I couldn't find close matches on Purple Post. Try different keywords or browse the Lost, Found, Rentals, and Marketplace pages."
      else
        "Here #{matches.size == 1 ? 'is' : 'are'} the closest #{matches.size} listing#{'s' unless matches.size == 1} I found on Purple Post."
      end
    end

    def empty_result
      {
        reply: "I couldn't find any listings to search. Try rephrasing your request.",
        matches: []
      }
    end
  end
end
