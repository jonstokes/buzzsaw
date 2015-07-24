require 'spec_helper'

class QueryDoc
  include Riffler
  attr_reader :doc
  attr_reader :url

  def initialize(doc)
    @doc = doc
    @url = "http://stretched.io/1"
  end
end

RSpec.describe Riffler do

  let(:file_name) { 'sample.html' }
  let(:base_doc)  {
    File.open(File.join('spec', 'fixtures', 'sample.html')) { |f| Nokogiri::HTML(f.read) }
  }
  let(:doc)       { QueryDoc.new(base_doc) }

  describe "#find_by_xpath" do
    it "finds the first matching node by xpath" do
      result = doc.find_by_xpath(xpath: "//div[@class='container']//li")
      expect(result).to eq("First Item")
    end

    it "takes a pattern argument" do
      result = doc.find_by_xpath(
        xpath:   "//div[@class='container']//li",
        pattern: /second/i
      )
      expect(result).to eq("Second")
    end

    it "takes a match argument" do
      result = doc.find_by_xpath(
        xpath: "//div[@class='container']//li",
        match: /second/i
      )
      expect(result).to eq("Second Item")
    end

    it "takes a capture argument" do
      result = doc.find_by_xpath(
        xpath:   "//div[@class='container']//li",
        capture: /first/i
      )
      expect(result).to eq("First")
    end

    it "takes match and capture arguments together" do
      result = doc.find_by_xpath(
        xpath:   "//div[@class='container']//li",
        match:   /Third/,
        capture: /item/i
      )
      expect(result).to eq("Item")
    end

    it "takes a label argument" do
      result = doc.find_by_xpath(
        xpath: "//div[@class='container']//li",
        match: /Third/,
        label: "Foo"
      )
      expect(result).to eq("Foo")
    end
  end

  describe "#collect_by_xpath" do
    it "collects nodes by xpath" do
      result = doc.collect_by_xpath(xpath: "//div[@class='container']//li")
      expect(result).to eq("First ItemSecond ItemThird ItemFourth Item")
    end

    it "uses a join argument" do
      result = doc.collect_by_xpath(
        xpath: "//div[@class='container']//li",
        join:  "|"
      )
      expect(result).to eq("First Item|Second Item|Third Item|Fourth Item")
    end
  end

  describe "#find_in_table" do
    it "takes a capture argument" do
      result = doc.find_in_table(
        xpath: "//table",
        row:   2,
        capture: /row/i
      )
      expect(result.strip.squeeze).to eq("Row")
    end

    context "row argument" do
      it "matches a row by number" do
        result = doc.find_in_table(
          xpath: "//table",
          row:   2
        )
        expect(result.strip.squeeze).to eq("Col 1, Row 2\n Col 2, Row 2")
      end

      it "matches a row by pattern" do
        result = doc.find_in_table(
          xpath: "//table",
          row:   /Col 1\, Row 2/
        )
        expect(result.strip.squeeze).to eq("Col 1, Row 2\n Col 2, Row 2")
      end
    end

    context "column argument" do
      it "matches a column by number" do
        result = doc.find_in_table(
          xpath:  "//table",
          row:    2,
          column: 2
        )
        expect(result.strip.squeeze).to eq("Col 2, Row 2")
      end

      it "matches a column by pattern" do
        result = doc.find_in_table(
          xpath:  "//table",
          row:    2,
          column: /Col 1/
        )
        expect(result.strip.squeeze).to eq("Col 1, Row 2")
      end
    end
  end
end
