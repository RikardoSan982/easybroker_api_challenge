# frozen_string_literal: true

require_relative "../lib/easybroker/client"
require_relative "../lib/easybroker/properties"

api_key = ENV.fetch("EASYBROKER_API_KEY") do
  warn "Falta la variable EASYBROKER_API_KEY"
  exit 1
end

client = EasyBroker::Client.new(api_key: api_key)
properties = EasyBroker::Properties.new(client: client)

properties.titles.each { |t| puts t }
