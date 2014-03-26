# encoding: utf-8
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'html2confluence'

describe HTMLToConfluenceParser, "when running JIRA examples" do
  
  before :all do
    html = <<-END
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
<blockquote><p>Some block quoted text</p></blockquote>

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


<div class="preformatted panel" style="border-width: 1px;"><div class="preformattedContent panelContent">
<pre>preformatted piece of text
 so *no* further _formatting_ is done here
</pre>
</div></div>
    END
    
    markup = <<-END
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
    END
    
    
    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    @textile = parser.to_wiki_markup
    #puts @textile
    #puts RedCloth.new(@textile).to_html
  end

  it "should convert heading tags" do
    @textile.should match(/^h1. Biggest heading/)
    @textile.should match(/^h2. Bigger heading/)
    @textile.should match(/^h3. Big heading/)
    @textile.should match(/^h4. Normal heading/)
    @textile.should match(/^h5. Small heading/)
    @textile.should match(/^h6. Smallest heading/)
  end
  
  it "should convert inline formatting" do
    @textile.should match(/^\*strong\*/)
    @textile.should match(/^_emphasis_/)
    @textile.should match(/^\?\?citation\?\?/)
    @textile.should match(/^-deleted-/)
    @textile.should match(/^\+inserted\+/)
    @textile.should match(/^\^superscript\^/)
    @textile.should match(/^\~subscript\~/)
    @textile.should match(/^\{\{monospaced\}\}/)
  end
  
  it "should convert block quotes" do
    @textile.should match(/^bq. Some block quoted text/)
    @textile.should match(/^\{quote\}\s*here is quotable\s*content to be quoted\s*{quote}/)
  end
  
  it "should handle text color" do
    @textile.should match(/^\{color\:red\}\s*look ma, red text!\s*\{color\}/)
  end
  
  it "should convert horizontal rules" do
    @textile.should match(/^---/)
  end
  
  it "should convert dashes" do
    @textile.should match(/^a -- b/)
    @textile.should match(/^a --- b/)
  end
  
  it "should convert links" do
    @textile.should match(/^\[\#anchor\]/)
    @textile.should match(/^\[http\:\/\/jira.atlassian.com\]/)
    @textile.should match(/^\[Atlassian\|http\:\/\/atlassian.com\]/)
    @textile.should match(/^\[file\:\/\/\/c\:\/temp\/foo.txt\]/)
  end
  
  it "should convert bullets" do
    @textile.should match(/\* some\s*\* bullet\s*\*\* indented\s*\*\* bullets\s*\* points/)
    @textile.should match(/- different\s*- bullet\s*- types/)
    @textile.should match(/# a\s*# numbered\s*# list/)
    @textile.should match(/# a\s*# numbered\s*#\* with\s*#\* nested\s*#\* bullet\s*# list/)
    @textile.should match(/\* a\s*\* bulleted\s*\*# with\s*\*# nested\s*\*# numbered\s*\* list/)
  end
  
  it "should convert pre blocks" do
    @textile.should match(/^\{noformat\}\s*preformatted piece of text\s*so \*no\* further _formatting_ is done here\s*\{noformat\}/)
  end
  
  it "should convert tables" do
    @textile.should include("sdfdsf")
  end
  
end
