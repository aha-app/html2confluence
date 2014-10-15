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
  
  it "should handle empty paragraphs" do
    html = <<-END
    <p>Previous</p><p><br></p><p><b>Scenario 4a: Existing deletes their ID</b><br>
    <b>Given</b> I am an existing user</p>
    END

    markup = "Previous\n\n*Scenario 4a: Existing deletes their ID*\n*Given* I am an existing user"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup.strip.should == markup
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
    parser.to_wiki_markup.strip.should == markup
  end
  
  it "don't remove extra newlines" do
    html = "<p><b>And</b> first line</p>\n\n<p><b><br></b></p><p><b>second line</b></p>\n\n"

    markup = "*And* first line\n\n*second line*"

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup.strip.should == markup
  end
end



