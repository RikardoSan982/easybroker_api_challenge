# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/easybroker/properties"

class FakeClient
  def initialize(pages)
    @pages = pages
  end

  def get(_path, params:)
    @pages.fetch(params[:page]) { { "content" => [] } }
  end
end

class PropertiesTest < Minitest::Test
  def test_titles_paginates_until_empty
    pages = {
      1 => { "content" => [{ "title" => "Prop 1" }, { "title" => "Prop 2" }] },
      2 => { "content" => [{ "title" => "Prop 3" }] },
      3 => { "content" => [] }
    }

    client = FakeClient.new(pages)
    props = EasyBroker::Properties.new(client: client, limit: 50)

    assert_equal ["Prop 1", "Prop 2", "Prop 3"], props.titles
  end
end
