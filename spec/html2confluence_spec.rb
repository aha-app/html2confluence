# encoding: utf-8
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'html2confluence'
#require 'redcloth'

describe HTMLToConfluenceParser, "when converting html to textile" do
  
  before :all do
    html = <<-END
    <div>
      
      Some text inside a div<br/>with two lines
      <h1 class="story.title entry-title" id="post-312">
      <img src="path_to_image.png" alt="Converting HTML to Textile with Ruby" />
        <a href="http://jystewart.net/process/2007/11/converting-html-to-textile-with-ruby/" rel="bookmark">Converting HTML to Textile with Ruby</a>
      </h1>
      
      <div class="note">A note</div><div class="note">Followed by another note</div>
    
      <p>
        <span>23 November 2007</span> 
        (<abbr class="updated" title="2007-11-23T19:51:54+00:00">7:51 pm</abbr>)
      </p>
        
      <p class='test'>
        By <span class="author vcard fn">James Stewart</span> <br />filed under: 
          <a href="http://jystewart.net/process/category/snippets/" title="View all posts in Snippets" rel="category tag">Snippets</a>
          <br />tagged: <a href="http://jystewart.net/process/tag/content-management/" rel="tag">content management</a>,
          <a href="http://jystewart.net/process/tag/conversion/" rel="tag">conversion</a>,
          <a href="http://jystewart.net/process/tag/html/" rel="tag">html</a>,
          <a href="http://jystewart.net/process/tag/python/" rel="tag">Python</a>,
          <a href="http://jystewart.net/process/tag/ruby/" rel="tag">ruby</a>,
          <a href="http://jystewart.net/process/tag/textile/" rel="tag">textile</a>
      </p>
      
      <p>test paragraph without id or class attributes</p>
      
      <p>test paragraph without closing tag</p>
      
      <p>Break not closed<br> at all</p>
      
      <li>test<strong> invalid </strong>list item 1</li>
      <li>test invalid list item 2</li>
      
      <ol>
        <li>test 1</li>
        <li>test 2<br/>with a line break in the middle</li>
        <li>test 3</li>
        <li> <br/></li>
      </ol>
      
      x&gt; y
      
      <blockquote>
        <p>paragraph inside a blockquote</p>
        <p>another paragraph inside a blockquote</p>
      </blockquote>
      
      <p>
        Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
        Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure 
        dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non 
        proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
      </p>
      <table cellpadding="3" style="color:red;" summary="a table with a caption">
        <caption>table caption</caption>
        <tr>
          <th>heading 1</th>
          <th>heading 2</th>
        </tr>
        <tr>
          <td>value 1</td>
          <td>value 2</td>
        </tr>
      </table>
      
      Hughes &amp; Hughes
      
      Something &amp; something else and <span rel="test">a useless span</span>
      
      Some text before a table<table summary="a table without a caption">
        <tr>
          <th>heading 1</th>
          <th>heading 2</th>
        </tr>
        <tr>
          <td>value 1</td>
          <td>value 2</td>
        </tr>
      </table>
      
      <p>
        <strong>Please apply online at:<br /></strong><a href="http://www.something.co.uk/careers">www.something.co.uk/careers</a></p>
      
      <p>test <strong><em>test emphasised bold text</em> </strong>test
      An ordinal number - 1<sup>st </sup>
      </p>

      <div class="feedback">
        Leave some feedback...<br/>
        <script src="http://feeds.feedburner.com/~s/jystewart/iLiN?i=http://jystewart.net/process/2007/11/converting-html-to-textile-with-ruby/" type="text/javascript" charset="utf-8"></script>
      </div>
      
      <p>&nbsp;<br/></p>
      <blockquote>&nbsp;<br/></blockquote>
      <strong>more bold text</strong><strong><br /></strong>

      <p>Some text with <u>underlining</u> is here.</p>

      <p>Æïœü</p>

      &copy; Copyright statement, let's see what happens to this&#8230; &euro; 100

      An unknown named entity reference - &unknownref; 

      <strike>strike 1</strike>
      <del>strike 2</del>

      # Not a list
      * Not a list
      - Not a list
      *Not bold*
      _Not a emph_
      {Not curly}
      |Not table
    </div>
    END
    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    @textile = parser.to_wiki_markup
    #puts @textile
    #puts RedCloth.new(@textile).to_html
  end

  it "should convert heading tags" do
    expect(@textile).to match(/^h1(\([^\)]+\))?\./)
  end
  
  it "should convert paragraph tags" do
    # We don't include paragraph classes expect(@textile).to match(/^p(\([^\)]+\))?\./)
  end
  
  it "should convert underline tags" do
    expect(@textile).to include("text with +underlining+ is here")
  end
  
  it "should not explicitly markup paragraphs unnecessarily" do
    expect(@textile).to_not include("p. test paragraph without id or class attributes")
  end
  
  it "should treat divs as block level elements, but ignore any attributes (effectively converting them to paragraphs)" do
    expect(@textile).to include("\n\nA note\n\nFollowed by another note\n\n")
  end
  
  it "should not convert pointless spans to textile (i.e. without supported attributes)" do
    expect(@textile).to_not include("%a useless span%")
  end

  it "should convert class and id attributes" do
    # We don't convert classes. expect(@textile).to include("h1(story.title entry-title#post-312).")
  end
  
  it "should convert tables" do
    expect(@textile).to include("\n\n||heading 1 ||heading 2 || \n|value 1 |value 2 | \n")
  end
  
  it "should convert tables with text immediately preceding the opening table tag" do
    expect(@textile).to include("Some text before a table\n\n||heading 1 ||heading 2 || \n|value 1 |value 2 | \n")
  end
  
  it "should respect line breaks within block level elements" do
    expect(@textile).to include("\n# test 1 \n# test 2\nwith a line break in the middle")
  end
  
  it "should handle paragraphs nested within blockquote" do
    expect(@textile).to include("{quote}\n\nparagraph inside a blockquote\n\nanother paragraph inside a blockquote\n\n{quote}")
  end
  
  it "should retain leading and trailing whitespace within inline elements" do
    expect(@textile).to include("test *invalid* list item 1")
  end
  
  it "should respect trailing line break tags within other elements" do
    expect(@textile).to include("*Please apply online at:*\n[www.something.co.uk/careers|http://www.something.co.uk/careers]")
  end
  
  it "should handle nested inline elements" do
    expect(@textile).to include(" *_test emphasised bold text_* test")
  end
  
  it "should remove empty quicktags before returning" do
    expect(@textile).to_not include("*more bold text* *\n*")
  end  
  
  it "should remove unsupported elements (e.g. script)" do
    expect(@textile).to_not include('script')
  end
  
  it "should remove unsupported attributes (i.e. everything but class and id)" do
    expect(@textile).to_not include('summary')
    expect(@textile).to_not include('a table with a caption')
    expect(@textile).to_not include('style')
    expect(@textile).to_not include('color:red;')
  end
  
  it "should clean up multiple blank lines created by tolerant parsing before returning" do
    expect(@textile).to_not match(/(\n\n\s*){2,}/)
  end
  
  it "should keep entity references" do
    expect(@textile).to include("&copy;")
  end
  
  it "should output unknown named entity references" do
    expect(@textile).to include("&unknownref;")
  end  
  
  it "should convert numerical entity references to a utf-8 character" do
    expect(@textile).to include("…")
  end

  it "should ignore entities that are already converted" do
    expect(@textile).to include("Æïœü")
  end
  
  it "should ignore ampersands that are not part of an entity reference" do
    expect(@textile).to include("Hughes & Hughes")
  end
  
  it "should retain whitespace surrounding entity references" do
    expect(@textile).to include("… &euro; 100")
    expect(@textile).to include("Something & something")
  end
  
  it "should escape special characters" do
    # This test currently fails. We would like it to pass, but only by escaping
    # characters that would otherwise be mistaken for markup. It should not
    # escape every instance of these characters.
    pending 'only escape correct characters'
    expect(@textile).to include("\\# Not a list")
    expect(@textile).to include("\\* Not a list")
    expect(@textile).to include("\\- Not a list")
    expect(@textile).to include("\\*Not bold\\*")
    expect(@textile).to include("\\_Not a emph\\_")
    expect(@textile).to include("\\{Not curly\\}")
    expect(@textile).to include("\\|Not table")
  end
  
  it "should support strikethrough" do
    expect(@textile).to include("-strike 1-")
    expect(@textile).to include("-strike 2-")
  end
  
  
end
