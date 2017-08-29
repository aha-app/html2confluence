require_relative 'spec_helper'

describe HTMLToConfluenceParser, "when running JIRA examples" do
  
  let(:html) do
    <<~HTML
      <h1><a name="Biggestheading"></a>Biggest heading</h1>
      <h2><a name="Biggerheading"></a>Bigger heading</h2>
      <h3><a name="Bigheading"></a>Big heading</h3>
      <h4><a name="Normalheading"></a>Normal heading</h4>
      <h5><a name="Smallheading"></a>Small heading</h5>
      <h6><a name="Smallestheading"></a>Smallest heading</h6>

      <p><b>strong</b><br/>
      <em>emphasis</em><br/>
      <cite>citation</cite><br/>
      <del>deleted</del><br/>
      <ins>inserted</ins><br/>
      <sup>superscript</sup><br/>
      <sub>subscript</sub><br/>
      <tt>monospaced</tt></p>
      <blockquote>Some block quoted text</blockquote>

      <blockquote>
      <p> here is quotable<br/>
       content to be quoted</p></blockquote>

      <p><font color="red"><br/>
          look ma, red text!</font></p>

      <p>a<br class="atl-forced-newline" />b</p>

      <p>a<br/>
      b</p>

      <hr />

      <p>a &#8211; b<br/>
      a &#8212; b</p>

      <p><a href="#anchor">anchor</a></p>

      <p><a href="http://jira.atlassian.com" class="external-link" rel="nofollow">http://jira.atlassian.com</a><br/>
      <a href="http://atlassian.com" class="external-link" rel="nofollow">Atlassian</a></p>

      <p><a href="file:///c:/temp/foo.txt" class="external-link" rel="nofollow">file:///c:/temp/foo.txt</a></p>

      <p><a name="anchorname"></a></p>

      <ul>
        <li>some</li>
        <li>bullet
        <ul>
          <li>indented</li>
          <li>bullets</li>
        </ul>
        </li>
        <li>points</li>
      </ul>


      <ul class="alternate" type="square">
        <li>different</li>
        <li>bullet</li>
        <li>types</li>
      </ul>


      <ol>
        <li>a</li>
        <li>numbered</li>
        <li>list</li>
      </ol>


      <ol>
        <li>a</li>
        <li>numbered
        <ul>
          <li>with</li>
          <li>nested</li>
          <li>bullet</li>
        </ul>
        </li>
        <li>list</li>
      </ol>


      <ul>
        <li>a</li>
        <li>bulleted
        <ol>
          <li>with</li>
          <li>nested</li>
          <li>numbered</li>
        </ol>
        </li>
        <li>list</li>
      </ul>


      <table class='confluenceTable'><tbody>
      <tr>
      <th class='confluenceTh'>heading 1</th>
      <th class='confluenceTh'>heading 2</th>
      <th class='confluenceTh'>heading 3</th>
      </tr>
      <tr>
      <td class='confluenceTd'>col A1</td>
      <td class='confluenceTd'>col A2</td>
      <td class='confluenceTd'>col A3</td>
      </tr>
      <tr>
      <td class='confluenceTd'>col B1</td>
      <td class='confluenceTd'>col B2</td>
      <td class='confluenceTd'>col B3</td>
      </tr>
      </tbody></table>

      <img src="https://somdomain.net/images/icons/emoticons/smile.gif">
      <img src="https://somdomain.net/images/icons/emoticons/warning.gif">
      <img src="/images/icons/emoticons/lightbulb.gif">
      <img src="https://bigaha.atlassian.net/images/icons/emoticons/check.png" />

      <div class="preformatted panel" style="border-width: 1px;"><div class="preformattedContent panelContent">
      <pre>preformatted piece of text
       so *no* further _formatting_ is done here
      </pre>
      </div></div>
    HTML
  end
  
  let(:markup) do
    <<~MARKUP
      h1. Biggest heading
      h2. Bigger heading
      h3. Big heading
      h4. Normal heading
      h5. Small heading
      h6. Smallest heading

      *strong*
      _emphasis_
      ??citation??
      -deleted-
      +inserted+
      ^superscript^
      ~subscript~
      {{monospaced}}
      bq. Some block quoted text

      {quote}
       here is quotable
       content to be quoted
      {quote}

      {color:red}
          look ma, red text!
      {color}

      a\\b

      a
      b

      ----

      a -- b
      a --- b

      [#anchor]

      [http://jira.atlassian.com]
      [Atlassian|http://atlassian.com]

      [file:///c:/temp/foo.txt]

      {anchor:anchorname}

      * some
      * bullet
      ** indented
      ** bullets
      * points

      - different
      - bullet
      - types

      # a
      # numbered
      # list

      # a
      # numbered
      #* with
      #* nested
      #* bullet
      # list

      * a
      * bulleted
      *# with
      *# nested
      *# numbered
      * list

      ||heading 1||heading 2||heading 3||
      |col A1|col A2|col A3|
      |col B1|col B2|col B3|

      {noformat}
      preformatted piece of text
       so *no* further _formatting_ is done here
      {noformat}
    MARKUP
  end

  it "should convert images within a link" do
    imagetarget = "https://example.com/image.jpg"
    link = "https://example.com/index.html"
    test_html = %{
      <p>
        <a href="#{link}" target="_blank">
          <img src="#{imagetarget}"
          alt=""
          width="300" />
        </a>
      </p>
    }

    parser = HTMLToConfluenceParser.new
    parser.feed test_html
    @textile = parser.to_wiki_markup

    expect(@textile).to eq("[!#{imagetarget}!|#{link}]")
  end

  it "should convert heading tags" do
    expect(html).to match_markup(/^h1. Biggest heading/)
    expect(html).to match_markup(/^h2. Bigger heading/)
    expect(html).to match_markup(/^h3. Big heading/)
    expect(html).to match_markup(/^h4. Normal heading/)
    expect(html).to match_markup(/^h5. Small heading/)
    expect(html).to match_markup(/^h6. Smallest heading/)
  end
  
  it "should convert inline formatting" do
    expect(html).to match_markup(/\*strong\*/)
    expect(html).to match_markup(/_emphasis_/)
    expect(html).to match_markup(/\?\?citation\?\?/)
    expect(html).to match_markup(/-deleted-/)
    expect(html).to match_markup(/\+inserted\+/)
    expect(html).to match_markup(/\^superscript\^/)
    expect(html).to match_markup(/\~subscript\~/)
    expect(html).to match_markup(/\{\{monospaced\}\}/)
  end
  
  it "should convert block quotes" do
    expect(html).to match_markup(/^bq. Some block quoted text/)
    expect(html).to match_markup(/^\{quote\}\s*here is quotable\s*content to be quoted\s*{quote}/)
  end
  
  it "should handle text color" do
    expect(html).to match_markup(/^\{color\:red\}\s*look ma, red text!\s*\{color\}/)
  end
  
  it "should convert horizontal rules" do
    expect(html).to match_markup(/^----/)
  end
  
  it "should convert dashes" do
    expect(html).to match_markup(/^a -- b/)
    expect(html).to match_markup(/^a --- b/)
  end
  
  it "should convert links" do
    expect(html).to match_markup(/^\[\#anchor\]/)
    expect(html).to match_markup(/^\[http\:\/\/jira.atlassian.com\]/)
    expect(html).to match_markup(/^\[Atlassian\|http\:\/\/atlassian.com\]/)
    expect(html).to match_markup(/^\[file\:\/\/\/c\:\/temp\/foo.txt\]/)
  end
  
  it "should convert bullets" do
    expect(html).to match_markup(/\* some\s*\* bullet\s*\*\* indented\s*\*\* bullets\s*\* points/)
    expect(html).to match_markup(/- different\s*- bullet\s*- types/)
    expect(html).to match_markup(/# a\s*# numbered\s*# list/)
    expect(html).to match_markup(/# a\s*# numbered\s*#\* with\s*#\* nested\s*#\* bullet\s*# list/)
    expect(html).to match_markup(/\* a\s*\* bulleted\s*\*# with\s*\*# nested\s*\*# numbered\s*\* list/)
  end
  
  it "should convert pre blocks" do
    expect(html).to match_markup(/^\{noformat\}\s*preformatted piece of text\s*so \*no\* further _formatting_ is done here\s*\{noformat\}/)
  end
  
  it "should convert tables" do
    expect(html).to include_markup("||heading 1 ||heading 2 ||heading 3 ||")
    expect(html).to include_markup("|col A1 |col A2 |col A3 |")
    expect(html).to include_markup("|col B1 |col B2 |col B3 |")
  end

  it "should convert emoji from jira" do
    expect(html).to include_markup(":)")
    expect(html).to include_markup("(!)")
    expect(html).to include_markup("(off)")
    expect(html).to include_markup("(/)")
  end
  
end
