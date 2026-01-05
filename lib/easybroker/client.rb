# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module EasyBroker
  class ApiError < StandardError; end
  class UnauthorizedError < ApiError; end

  class Client
    DEFAULT_BASE_URL = "https://api.stagingeb.com".freeze

    def initialize(api_key:, base_url: DEFAULT_BASE_URL, http: Net::HTTP)
      @api_key = api_key
      @base_url = base_url
      @http = http
    end

    def get(path, params: {})
      uri = build_uri(path, params)
      req = Net::HTTP::Get.new(uri)
      req["Accept"] = "application/json"
      req["X-Authorization"] = @api_key

      res = @http.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |h|
        h.request(req)
      end

      handle_response(res)
    end

    private

    def build_uri(path, params)
      uri = URI.join(@base_url, path)
      uri.query = URI.encode_www_form(params) unless params.empty?
      uri
    end

    def handle_response(res)
      case res.code.to_i
      when 200..299
        JSON.parse(res.body)
      when 401
        raise UnauthorizedError, "API key missing/invalid (401)"
      else
        raise ApiError, "Request failed (#{res.code}): #{res.body}"
      end
    end
  end
end
