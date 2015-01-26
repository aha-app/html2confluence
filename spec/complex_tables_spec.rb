# encoding: utf-8
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'html2confluence'

describe HTMLToConfluenceParser, "when running complex tables examples" do
  
   it "should handle table with newlines" do
    html = <<-END
    <table class="mce-item-table"><tbody><tr><td>As a...</td><td>I would like...</td><td>Because...</td></tr><tr><td><p>Student<br>or</p><p>Teacher</p></td><td>There to be more candy</td><td><p>Candy is:</p><ul><li>Delicious</li><li>Shiny</li><li>Good for my teeth</li></ul></td></tr></tbody></table>
    END

    markup = <<-END
|As a...|I would like...|Because...|
|Student
or
\\\\
Teacher|There to be more candy|Candy is:
\\\\
* Delicious
* Shiny
* Good for my teeth|
    END

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup.strip.should include(markup.strip)
  end
  
   it "should handle table empty cells" do
    html = <<-END
    <table class="mce-item-table"><tbody><tr><td><p><br data-mce-bogus="1"></p></td><td>Empty</td><td><p><br data-mce-bogus="1"></p></td></tr></tbody></table>
    END

    markup = <<-END
| |Empty| |
    END

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    parser.to_wiki_markup.strip.should include(markup.strip)
  end
  
end



