require "riffler/version"

module Riffler
  #
  # Doc query methods
  #

  def find_by_xpath(args)
    args.symbolize_keys!
    args[:match] = args[:capture] = args[:pattern] if args[:pattern]
    return bc_find_by_xpath(args) if args[:all_nodes]

    nodes = get_nodes(args)
    target = find_target_text(args, nodes)
    return args[:label] if args[:label] && target.present?
    asciify_target_text(target)
  end
  alias_method :label_by_xpath, :find_by_xpath # label_by_ is depreciated

  def collect_by_xpath(args)
    args.symbolize_keys!
    args[:match] = args[:capture] = args[:pattern] if args[:pattern]

    nodes = get_nodes(args)
    target = collect_target_text(args, nodes)
    return args[:label] if args[:label] && target.present?
    asciify_target_text(target)
  end

  def find_in_table(args)
    args.symbolize_keys!

    xpath   = args[:xpath]
    capture = args[:capture]

    if args[:row].is_a?(Fixnum)
      match_row = nil
      row_index = args[:row]
    else
      row_index = nil
      match_row = args[:row]
    end

    if args[:column].is_a?(Fixnum)
      match_column = nil
      column_index = args[:column]
    else
      column_index = nil
      match_column = args[:column]
    end

    return unless table = doc.at_xpath(xpath)

    # Rows match first
    return unless row = match_table_element(table, "tr", match_row, row_index)
    return row.text unless match_column || column_index

    # Now columns
    return unless col = match_table_element(row, "td", match_column, column_index)

    return col.text unless capture
    col.text[capture]
  end

  def match_table_element(table, element, match, index)
    row = nil
    row = table.xpath(".//#{element}").detect { |r| r.text && r.text[match] } if match
    row ||= table.xpath(".//#{element}[#{index}]") if index
    row
  end

  def find_by_meta_tag(args)
    args.symbolize_keys!
    args[:pattern] ||= args[:match] # Backwards compatibility

    nodes = get_nodes_for_meta_attribute(args)
    return unless target = get_content_for_meta_nodes(nodes)
    target = target[args[:pattern]] if args[:pattern]
    return args[:label] if args[:label] && target.present?
    target
  end
  alias_method :label_by_meta_tag, :find_by_meta_tag

  def find_by_schema_tag(value)
    string_methods = [:upcase, :downcase, :capitalize]
    nodes = string_methods.map do |method|
      doc.at_xpath("//*[@itemprop=\"#{value.send(method)}\"]")
    end.compact
    return if nodes.empty?
    content = nodes.first.text.strip.gsub(/\s+/," ")
    return unless content.present?
    content
  end

  def label_by_url(args)
    args.symbolize_keys!
    return args[:label] if "#{url}"[args[:pattern]]
  end

  #
  # Meta tag convenience methods
  #
  def meta_property(args)
    args.symbolize_keys!
    args.merge!(attribute: 'property')
    find_by_meta_tag(args)
  end

  def meta_name(args)
    args.symbolize_keys!
    args.merge!(attribute: 'name')
    find_by_meta_tag(args)
  end

  def meta_og(value);   meta_property(value: "og:#{value}"); end

  def meta_title;       meta_name(value: 'title'); end
  def meta_keywords;    meta_name(value: 'keywords'); end
  def meta_description; meta_name(value: 'description'); end
  def meta_image;       meta_name(value: 'image'); end
  def meta_price;       meta_name(value: 'price'); end

  def meta_og_title;       meta_og('title'); end
  def meta_og_keywords;    meta_og('keywords'); end
  def meta_og_description; meta_og('description'); end
  def meta_og_image;       meta_og('image'); end

  def label_by_meta_keywords(args)
    args.symbolize_keys!
    return args[:label] if meta_keywords && meta_keywords[args[:pattern]]
  end

  #
  # Schema.org convenience mthods
  #

  def schema_price;       find_by_schema_tag("price"); end
  def schema_name;        find_by_schema_tag("name"); end
  def schema_description; find_by_schema_tag("description"); end

  def filter_target_text(target, filter_list)
    filter_list.each do |filter|
      next unless target.present?
      filter.symbolize_keys! if filter.is_a?(Hash)
      if filter.is_a?(String) && respond_to?(filter)
        target = send(filter, target)
      elsif filter[:accept]
        target = target[filter[:accept]]
      elsif filter[:reject]
        target.slice!(filter[:reject])
      elsif filter[:prefix]
        target = "#{filter[:prefix]}#{target}"
      elsif filter[:postfix]
        target = "#{target}#{filter[:postfix]}"
      end
    end
    target.try(:strip)
  end

  alias_method :filters, :filter_target_text

  #
  # Private
  #

  def bc_find_by_xpath(args)
    args[:include] = args[:pattern]
    collect_by_xpath(args)
  end

  def find_target_text(args, nodes)
    match_target_text!(nodes, args[:match])

    # Select the first match
    result = nodes.first.try(:strip)

    # Filter match with the :capture regex
    capture_target_text(result, args[:capture])
  rescue Java::JavaNioCharset::UnsupportedCharsetException
  end

  def collect_target_text(args, nodes)
    match_target_text!(nodes, args[:match])

    # Reduce the matching nodes
    result = join_target_text(nodes, args[:join])

    # Filter the string with the :capture regex
    capture_target_text(result, args[:capture])
  rescue Java::JavaNioCharset::UnsupportedCharsetException
  end

  def match_target_text!(nodes, pattern)
    return unless nodes.present?
    nodes.select! do |node|
      pattern ? node[pattern].present? : node.present?
    end
  end

  def capture_target_text(text, pattern)
    return unless text
    pattern ? text[pattern] : text.gsub(/\s+/," ")
  end

  def join_target_text(nodes, delimiter)
    return unless nodes.present?
    delimiter = delimiter.to_s
    nodes.inject { |a, b| a.to_s + delimiter + b.to_s }
  end

  def sanitize(text)
    return unless str = Sanitize.clean(text, elements: [])
    HTMLEntities.new.decode(str)
  end

  def get_nodes(args)
    nodes = doc.xpath(args[:xpath])
    nodes.map(&:text).compact
  end

  def get_nodes_for_meta_attribute(args)
    attribute = args[:attribute]
    value_variations = [:upcase, :downcase, :capitalize].map { |method| args[:value].send(method) }
    nodes = value_variations.map do |value|
      doc.at_xpath("//head/meta[@#{attribute}=\"#{value}\"]")
    end.compact
    return if nodes.empty?
    nodes
  end

  def get_content_for_meta_nodes(nodes)
    return unless nodes && nodes.any?
    contents = nodes.map { |node| node.attribute("content") }.compact
    return if contents.empty?
    content = contents.first.value.strip.squeeze(" ")
    return unless content.present?
    content
  end

  def asciify_target_text(target)
    return unless target
    newstr = ""
    target.each_char { |chr| newstr << (chr.dump["u{e2}"] ? '"' : chr) }
    newstr.to_ascii
  end
end
