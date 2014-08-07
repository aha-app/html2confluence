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

   it "should match nested lists" do
    html = <<-END
    <p>One line</p>
    <ul>
      <li>Nested</li>
      <ol>
        <li>bullets</li>
        <li>go</li>
        <li>here</li>
        <ol>
          <li>dfsdf</li>
          <li>dsfs</li>
        </ol>
      </ol>
      <li>Final bullet</li>
    </ul>
    
    <h1>With <u>nice</u> formatting.</h1>
    END

    markup = <<-END
One line

* Nested 
*# bullets 
*# go 
*# here 
*## dfsdf 
*## dsfs  
* Final bullet 

h1. With +nice+ formatting.
    END

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup.strip.should include(markup.strip)
  end
  
  it "should match nested blockquotes" do
    html = <<-END
<blockquote><blockquote>content here</blockquote></blockquote>
    END

    markup = <<-END
{quote}\nbq. content here\n{quote}
    END


    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup.strip.should include(markup.strip)
  end
end



