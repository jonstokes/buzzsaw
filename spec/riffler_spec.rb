require 'spec_helper'

class QueryDoc
  include Riffler
  attr_reader :doc

  def initialize(doc)
    @doc = doc
  end
end

RSpec.describe Riffler do
  describe "#find_by_xpath" do
    it "does stuff" do
    end
  end
end
