# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/easybroker/client"

class FakeHTTP
  Response = Struct.new(:code, :body)

  def initialize(codes)
    @codes = codes.dup
  end

  def start(_host, _port, use_ssl:)
    yield self
  end

  def open_timeout=(_); end
  def read_timeout=(_); end

  def request(_req)
    code = @codes.shift || 200
    body = (code == 200) ? '{"ok":true}' : '{"error":"nope"}'
    Response.new(code.to_s, body)
  end
end

class ClientRetryTest < Minitest::Test
  def test_retries_on_429_then_succeeds
    http = FakeHTTP.new([429, 200])
    client = EasyBroker::Client.new(api_key: "x", http: http, retries: 2, backoff_base: 0)
    assert_equal({"ok" => true}, client.get("/v1/properties", params: { page: 1, limit: 1 }))
  end
end
