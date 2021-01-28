# encoding: utf-8
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'html2confluence'

describe HTMLToConfluenceParser, "when running checkbox examples" do

  it "should match checkboxes" do
    html = <<-END
    <div class="wiki text common-markdown"><ul class="markdown-checkbox-list">
    <li><label><input type="checkbox" data-position="0" checked="">Example 1</label></li>
    <li><label><input type="checkbox" data-position="1" checked="">Example 2</label></li>
    <li><label><input type="checkbox" data-position="2">Example 3</label></li>
    <li><label><input type="checkbox" data-position="3" checked="">Example 4</label></li>
    <li><label><input type="checkbox" data-position="4">Example 5</label></li>
    </ul>
    </div>
    END

    markup = <<-END
* (/) Example 1
* (/) Example 2
* (x) Example 3
* (/) Example 4
* (x) Example 5
    END

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
  end
  
end
