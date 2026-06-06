# frozen_string_literal: true

require "faraday"
require "json"

class GeminiClient
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ApiError < Error; end
  class ResponseError < Error; end

  GENERATE_URL = "https://generativelanguage.googleapis.com/v1beta/models/%<model>s:generateContent"

  def self.generate_json(prompt:, system: nil)
    new.generate_json(prompt: prompt, system: system)
  end

  def initialize(api_key: nil, model: nil, connection: nil)
    @api_key = api_key.presence || Rails.application.config.x.gemini_api_key
    @model = model.presence || Rails.application.config.x.gemini_model
    @connection = connection
  end

  def generate_json(prompt:, system: nil)
    payload = {
      contents: build_contents(prompt: prompt, system: system),
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.2
      }
    }

    body = request!(payload)
    text = extract_text(body)
    parse_json!(text)
  end

  private

  def build_contents(prompt:, system:)
    parts = []
    parts << { text: system } if system.present?
    parts << { text: prompt }
    [ { parts: parts } ]
  end

  def request!(payload)
    raise ConfigurationError, "Set GEMINI_API_KEY to use the AI assistant." if @api_key.blank?

    response = connection.post(url, payload.to_json)

    unless response.success?
      detail = extract_api_error(response.body)
      raise ApiError, "Gemini request failed (#{response.status})#{detail}"
    end

    JSON.parse(response.body)
  rescue Faraday::Error => e
    raise ApiError, "Could not reach Gemini (#{e.class.name.demodulize})."
  rescue JSON::ParserError
    raise ApiError, "Gemini returned an invalid response."
  end

  def extract_api_error(body)
    parsed = JSON.parse(body)
    message = parsed.dig("error", "message").to_s.strip
    message.present? ? ": #{message}" : ""
  rescue JSON::ParserError
    ""
  end

  def connection
    @connection ||= Faraday.new do |f|
      f.headers["Content-Type"] = "application/json"
      f.adapter Faraday.default_adapter
    end
  end

  def url
    format(GENERATE_URL, model: @model) + "?key=#{CGI.escape(@api_key)}"
  end

  def extract_text(body)
    candidates = body["candidates"]
    raise ResponseError, "Gemini returned no candidates." if candidates.blank?

    parts = candidates.dig(0, "content", "parts")
    text = parts&.filter_map { |part| part["text"] }&.join
    raise ResponseError, "Gemini returned an empty reply." if text.blank?

    text
  end

  def parse_json!(text)
    JSON.parse(text)
  rescue JSON::ParserError
    raise ResponseError, "Gemini returned invalid JSON."
  end
end
