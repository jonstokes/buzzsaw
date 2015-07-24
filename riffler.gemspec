# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'riffler/version'

Gem::Specification.new do |spec|
  spec.name          = "riffler"
  spec.version       = Riffler::VERSION
  spec.authors       = ["Jon Stokes"]
  spec.email         = ["jon@jonstokes.com"]
  spec.summary       = %q{A web scraping DSL built on Nokogiri}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "htmlentities", "~> 4.3"
  spec.add_dependency "nokogiri", "~> 1.6.6"
  spec.add_dependency "activesupport", "~> 4.2"
  spec.add_dependency "stringex", "~> 2.5"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
end
