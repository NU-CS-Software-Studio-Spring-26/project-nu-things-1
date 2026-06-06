# frozen_string_literal: true

module Assistant
  module SearchTerms
    STOP_WORDS = %w[
      a an the and or for to of in on at by with from as is are am was were be been being
      i me my we you your it its this that these those what which who how when where why
      do does did have has had can could will would should may might must
      looking look find found search searching want wanted need needed get got buy sell rent borrow
      something anything item items listing listings post posted
    ].freeze

    module_function

    def extract(raw_terms, fallback_text: nil)
      words = Array(raw_terms).flat_map { |term| term.to_s.downcase.split(/\s+/) }
      words = fallback_text.to_s.downcase.split(/\s+/) if words.empty?
      words.reject { |word| stop_word?(word) }.uniq
    end

    def best_keyword(raw_terms, fallback_text: nil)
      extract(raw_terms, fallback_text: fallback_text).max_by(&:length)
    end

    def stop_word?(word)
      word.blank? || STOP_WORDS.include?(word) || word.length < 2
    end
  end
end
