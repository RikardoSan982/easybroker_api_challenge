# frozen_string_literal: true

module EasyBroker
  class Properties
    PATH = "/v1/properties"

    def initialize(client:, limit: 50)
      @client = client
      @limit = limit
    end

    def each
      return enum_for(:each) unless block_given?

      page = 1

      loop do
        data = @client.get(PATH, params: { page: page, limit: @limit })
        content = Array(data["content"])

        break if content.empty?

        content.each { |property| yield property }
        page += 1
      end
    end

    def titles
      each.map { |p| p["title"] }.compact
    end
  end
end
