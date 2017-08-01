require 'spec_helper'

describe HTMLToConfluenceParser, "when converting html to textile" do
  
  let :html do
    <<~HTML
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
    HTML
  end

  it "should convert heading tags" do
    expect(html).to match_markup(/^h1(\([^\)]+\))?\./)
  end
  
  it "should convert paragraph tags" do
    # We don't include paragraph classes expect(@textile).to match(/^p(\([^\)]+\))?\./)
  end
  
  it "should convert underline tags" do
    expect(html).to include_markup("text with +underlining+ is here")
  end
  
  it "should not explicitly markup paragraphs unnecessarily" do
    expect(html).not_to include_markup("p. test paragraph without id or class attributes")
  end
  
  it "should treat divs as block level elements, but ignore any attributes (effectively converting them to paragraphs)" do
    expect(html).to include_markup("\n\nA note\n\nFollowed by another note\n\n")
  end
  
  it "should not convert pointless spans to textile (i.e. without supported attributes)" do
    expect(html).not_to include_markup("%a useless span%")
  end

  # it "should convert class and id attributes" do
  #   # We don't convert classes. 
  #   expect(html).to include_markup("h1(story.title entry-title#post-312).")
  # end
  
  it "should convert tables" do
    expect(html).to include_markup("\n\n||heading 1 ||heading 2 || \n|value 1 |value 2 | \n")
  end
  
  it "should convert tables with text immediately preceding the opening table tag" do
    expect(html).to include_markup("Some text before a table\n\n||heading 1 ||heading 2 || \n|value 1 |value 2 | \n")
  end
  
  it "should respect line breaks within block level elements" do
    expect(html).to include_markup("\n# test 1 \n# test 2\nwith a line break in the middle")
  end
  
  it "should handle paragraphs nested within blockquote" do
    expect(html).to include_markup("{quote}\n\nparagraph inside a blockquote\n\nanother paragraph inside a blockquote\n\n{quote}")
  end
  
  it "should retain leading and trailing whitespace within inline elements" do
    expect(html).to include_markup("test *invalid* list item 1")
  end
  
  it "should respect trailing line break tags within other elements" do
    expect(html).to include_markup("*Please apply online at:*\n[www.something.co.uk/careers|http://www.something.co.uk/careers]")
  end
  
  it "should handle nested inline elements" do
    expect(html).to include_markup(" *_test emphasised bold text_* test")
  end
  
  it "should remove empty quicktags before returning" do
    expect(html).not_to include_markup("*more bold text* *\n*")
  end  
  
  it "should remove unsupported elements (e.g. script)" do
    expect(html).not_to include_markup('script')
  end
  
  it "should remove unsupported attributes (i.e. everything but class and id)" do
    expect(html).not_to include_markup('summary')
    expect(html).not_to include_markup('a table with a caption')
    expect(html).not_to include_markup('style')
    expect(html).not_to include_markup('color:red;')
  end
  
  it "should clean up multiple blank lines created by tolerant parsing before returning" do
    expect(html).not_to match_markup(/(\n\n\s*){2,}/)
  end
  
  it "should keep entity references" do
    expect(html).to include_markup("&copy;")
  end
  
  it "should output unknown named entity references" do
    expect(html).to include_markup("&unknownref;")
  end  
  
  it "should convert numerical entity references to a utf-8 character" do
    expect(html).to include_markup("…")
  end

  it "should ignore entities that are already converted" do
    expect(html).to include_markup("Æïœü")
  end
  
  it "should ignore ampersands that are not part of an entity reference" do
    expect(html).to include_markup("Hughes & Hughes")
  end
  
  it "should retain whitespace surrounding entity references" do
    expect(html).to include_markup("… &euro; 100")
    expect(html).to include_markup("Something & something")
  end
  
  it "should escape special characters" do
    # This test currently fails. We would like it to pass, but only by escaping
    # characters that would otherwise be mistaken for markup. It should not
    # escape every instance of these characters.
    pending 'only escape correct characters'
    expect(html).to include_markup("\\# Not a list")
    expect(html).to include_markup("\\* Not a list")
    expect(html).to include_markup("\\- Not a list")
    expect(html).to include_markup("\\*Not bold\\*")
    expect(html).to include_markup("\\_Not a emph\\_")
    expect(html).to include_markup("\\{Not curly\\}")
    expect(html).to include_markup("\\|Not table")
  end
  
  it "should support strikethrough" do
    expect(html).to include_markup("-strike 1-")
    expect(html).to include_markup("-strike 2-")
  end
  
end
