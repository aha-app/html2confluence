$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'html2confluence'

require 'rspec'

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
end

require 'rspec/expectations'

module MarkupHelpers
  module_function
  
  def html_to_markup(html)
    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup
  end
  
  def indent(markup)
    if markup.kind_of? String
      markup.lines.map{|l| "  #{l}"}.join
    else
      "  #{markup.inspect}"
    end
  end
  
end

RSpec::Matchers.define :match_markup do |markup|
  include MarkupHelpers
  
  diffable
  
  match do |html|
    @html = html
    @actual = html_to_markup(html).strip
    @markup = markup
    case markup
    when String
      values_match? @markup.strip, @actual
    when Regexp
      !!markup.match(@actual)
    end
  end
  
  failure_message do |html|
    <<~ERR
    expected that the parsed HTML:
    #{indent @html}
    
    would produce markup matching:
    #{indent @markup}
    
    instead, the parser produced:
    #{indent @actual}
    ERR
  end
end

RSpec::Matchers.define :include_markup do |markup|
  include MarkupHelpers
  
  diffable
  
  match do |html|
    @html = html
    @actual = html_to_markup(html).strip
    @markup = markup.strip
    @actual.include? @markup
  end
  
  failure_message do |html|
    <<~ERR
    expected that the parsed HTML:
    #{indent @html}
    
    would include markup:
    #{indent @markup}
    
    instead, the parser produced:
    #{indent @actual}
    ERR
  end
end
