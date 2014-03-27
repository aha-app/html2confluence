# encoding: utf-8
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'html2confluence'

describe HTMLToConfluenceParser, "when running combination examples" do
  
  it "should match complex examples" do
    html = <<-END
<ol>
	<li>a</li>
	<li>numbered <b>item</b> that is <u>underlined</u>.</li>
	<li>list</li>
</ol>
    END
    
    markup = <<-END
# a 
# numbered *item* that is +underlined+. 
# list
    END
    
    
    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup.strip.should include(markup.strip)
  end
  
end
