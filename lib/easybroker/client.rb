# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module EasyBroker
  class ApiError < StandardError; end
  class UnauthorizedError < ApiError; end
  class RateLimitedError < ApiError; end

  class Client
    DEFAULT_BASE_URL = "https://api.stagingeb.com".freeze

    def initialize(api_key:, base_url: DEFAULT_BASE_URL, http: Net::HTTP, retries: 3, backoff_base: 0.5)
      @api_key = api_key
      @base_url = base_url
      @http = http
      @retries = retries
      @backoff_base = backoff_base
    end

    def get(path, params: {})
      uri = build_uri(path, params)
      req = Net::HTTP::Get.new(uri)
      req["Accept"] = "application/json"
      req["X-Authorization"] = @api_key

      with_retries do
        res = request(uri, req)
        handle_response(res)
      end
    end

    private

    def request(uri, req)
      @http.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |h|
        h.open_timeout = 5
        h.read_timeout = 10
        h.request(req)
      end
    end

    def build_uri(path, params)
      uri = URI.join(@base_url, path)
      uri.query = URI.encode_www_form(params) unless params.empty?
      uri
    end

    def handle_response(res)
      code = res.code.to_i

      return JSON.parse(res.body) if code.between?(200, 299)
      raise UnauthorizedError, "API key missing/invalid (401)" if code == 401
      raise RateLimitedError, "Rate limited (429)" if code == 429

      raise ApiError, "Request failed (#{code}): #{res.body}"
    end

    def with_retries
      attempts = 0

      begin
        yield
      rescue RateLimitedError, ApiError => e
        attempts += 1

        transient = e.is_a?(RateLimitedError) || e.message.include?("(5")
        raise unless transient && attempts <= @retries

        sleep(@backoff_base * (2 ** (attempts - 1)))
        retry
      end
    end
  end
end
