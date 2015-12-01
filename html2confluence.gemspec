Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'html2confluence'
  s.version     = "1.3.13"
  s.summary     = 'Converter from HTML to Confluence Wiki Markup'
  s.description = 'Provides an SGML parser to convert HTML into the Wiki Markup format'

  s.required_ruby_version     = '>= 1.8.6'
  s.required_rubygems_version = ">= 1.3.6"

  s.authors           = ['k1w1', 'James Stewart', 'Mark Woods']
  s.homepage          = 'http://github.com/k1w1/html2confluence'

  s.require_path = 'lib'
  s.files        = Dir.glob("{lib,spec}/**/*") + %w(example.rb README.mdown)

  s.add_dependency "nokogiri"
end
