# Riffler

A DSL that wraps around `Nokogiri` and is used by stretched.io for web scraping.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'riffler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install riffler

## Usage

TODO: Write usage instructions here

## Query DSL

### find_by_xpath

Most of the time when I'm scraping the web, I just want to find the first
bit of matching text at a matching xpath. That's why `find_by_xpath` is the workhorse
of this query DSL.

This method takes the following arguments:
 - `xpath`: The xpath query string of the nodes that you want to search for a given pattern.
 - `match`: A regex that the text of the xpath node should match.
 - `capture`: A regex that pulls only the matching text out of the matched string and returns it.
 - `pattern`: If the `pattern` argument is present, then `match = capture = pattern`.

Here's a look at how `find_by_xpath` works in practice.

**Example**

Let's say that you want to extract the price of `product2` from the following bit of HTML:

 ```html
 <div id="product1-details">
  <ul>
    <li>Status: In-stock</li>
    <li>UPC: 00110012232</li>
    <li>Price: $12.99</li>
  </ul>
 </div>

 <div id="product2-details">
  <ul>
    <li>Status: In-stock</li>
    <li>UPC: 00110012232</li>
    <li>SKU: ITEM-2</li>
    <li>Price: $12.99</li>
  </ul>
 </div>
 ```
You might use `find_by_xpath` as follows:
```ruby
find_by_xpath(
  xpath: '//div[@id="product2-details"]//li',
  pattern: /\$[0-9]+\.[0-9]+/i
)
#=> "$12.99"
```
If for whatever reason you wanted that entire price node, you could do:

```ruby
find_by_xpath(
  xpath: '//div[@id="product2-details"]',
  match: /\$[0-9]+\.[0-9]+/i
)
#=> "Price: $12.99"
```
Now let's say that you only want "12.99", without the dollar sign. You could do
that as follows:
```ruby
find_by_xpath(
  xpath: '//div[@id="product2-details"]',
  match: /\$[0-9]+\.[0-9]+/i
  capture: /[0-9]+\.[0-9]/i
)
#=> "12.99"
```
These examples are contrived, but you get the idea.

### collect_by_xpath
Consider the `<ul>` of product details above. Let's say that I want
it capture and store those details as a human-readable string. If I have a `Nokogiri::Document` called
`doc` with the above HTML in it, then look at the following:

```ruby
doc.xpath("//div[@id='product2-details']//li").text
#=> Status: In-stockUPC: 00110012232SKU: ITEM-2Price: $12.99
```

All of the nodes are crammed together, but it would be nice if I could insert
a space in between them. That's one place where `collect_by_xpath` helps.

```ruby
collect_by_xpath(
  xpath: "//div[@id='product2-details']//li",
  join: ' '
)
#=> Status: In-stock UPC: 00110012232 SKU: ITEM-2 Price: $12.99
```
This method also takes the same `match`, `capture`, and `pattern` arguments
as `find_by_xpath`, and they do the same thing.


## Contributing

1. Fork it ( https://github.com/jonstokes/riffler/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
