require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'active_support/all'
require 'htmlentities'
require 'stringex'
require 'nokogiri'
require 'riffler'

RSpec.configure do |config|
  config.order = 'random'
end
