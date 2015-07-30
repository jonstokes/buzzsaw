module Buzzsaw
  class Document
    include Buzzsaw::DSL
    attr_reader :doc

    def initialize(source, format: nil)
      @doc = if format == :html
        Nokogiri::HTML(source)
      elsif format == :xml
        Nokogiri::XML(source)
      else
        Nokogiri.parse(source)
      end
    end
  end
end
