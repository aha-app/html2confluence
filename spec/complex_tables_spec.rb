# encoding: utf-8

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
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
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
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
  end
  
   it "should handle pre in table empty cells" do
    html = <<-END
    <table><tbody><tr><td><pre>a</pre></td><td>d</td></tr><tr><td><pre>b</pre></td><td>c</td></tr></tbody></table>
    END

    markup = <<-END
|{noformat}
a{noformat} |d |
|{noformat}
b{noformat} |c |
    END

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
  end
  
   it "should handle pre in table" do
    html = <<-END
    <table><tbody>
      <tr>
        <td>A </td>
        <td><tt>B</tt> </td>
        <td>C </td>
      </tr>
      <tr>
        <td>1 </td>
        <td><pre>2</pre></td>
        <td>3 </td>
      </tr>
    </tbody></table>
    END

    markup = <<-END
|A |{{B}} |C | 
|1 |{noformat}
2{noformat} |3  |
    END

    parser = HTMLToConfluenceParser.new
    parser.feed(html)
    expect(parser.to_wiki_markup.strip).to include(markup.strip)
  end
  
end



