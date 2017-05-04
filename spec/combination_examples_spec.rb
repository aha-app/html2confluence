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
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
  end

   it "should match nested lists" do
    html = <<-END
    <p>One line</p>
    <ul>
      <li>Nested</li>
      <li>
        <ol>
          <li>bullets</li>
          <li>go</li>
          <li>here</li>
          <li>
            <ol>
              <li>dfsdf</li>
              <li>dsfs</li>
            </ol>
          </li>
        </ol>
      </li>
      <li>Final bullet</li>
    </ul>

    <p>More stuff too</p>

    <ul>
      <li>In</li>
      <li>
        <ul>
          <li>and</li>
        </ul>
      </li>
      <li>out</li>
      <li>
        <ol>
          <li>with numbers</li>
          <li>
            <ul>
              <li>and sub-bullets</li>
            </ul>
          </li>
        </ol>
      </li>
      <li>and back out</li>
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

More stuff too

* In 
** and 
* out 
*# with numbers 
*#* and sub-bullets  
* and back out 

h1. With +nice+ formatting.
    END

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
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
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
  end
  
  it "should handle empty paragraphs" do
    html = <<-END
    <p>Previous</p><p><br></p><p><b>Scenario 4a: Existing deletes their ID</b><br>
    <b>Given</b> I am an existing user</p>
    END

    markup = "Previous\n\n*Scenario 4a: Existing deletes their ID*\n*Given* I am an existing user"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
  end
  
  it "should handle empty bold sections" do
    html = <<-END
    <p>Previous line</p>
    <p><b><br></b> <b>Scenario 4a: Existing deletes their ID</b><br>
    <b>Given</b> I am an existing user</p>
    END

    markup = "Previous line\n\n*Scenario 4a: Existing deletes their ID*\n*Given* I am an existing user"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
  end
  
  it "doesn't remove extra newlines" do
    html = "<p><b>And</b> first line</p>\n\n<p><b><br></b></p><p><b>second line</b></p>\n\n"

    markup = "*And* first line\n\n*second line*"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
  end
  
  it "handles unclosed img tags" do
    html = "<div><img src='a source'></div>\n\n"

    markup = "!a source!"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
  end
  
  it "handles wbr tags" do
    html = "<div>familiar with the XML<wbr>Http<wbr>Request Object</div>\n\n"

    markup = "familiar with the XMLHttpRequest Object"
    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
    
  end
  
  it "should handle unclosed tags" do
    html = <<-END
    <p>Previous line</p>
    <hr>
    END

    markup = "Previous line\n\n----"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
  end
  
  it "should handle HTML comments" do
    html = <<-END
    <p><!--?rh-implicit_p?--><span style=\"font-style: italic;\">A</span></p>
    END

    markup = "A"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
  end
  
  it "should handle CDATA elements" do
    html = <<-END
    <p>A</p>
    <![CDATA[Comment inside cdata]]>
    END

    markup = "A"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to eq(markup)
  end
  
end



