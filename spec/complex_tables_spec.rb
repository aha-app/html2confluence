require_relative 'spec_helper'

describe HTMLToConfluenceParser, "when running complex tables examples" do
  
   it "should handle table with newlines" do
    html = <<~HTML
      <table class="mce-item-table"><tbody><tr><td>As a...</td><td>I would like...</td><td>Because...</td></tr><tr><td><p>Student<br>or</p><p>Teacher</p></td><td>There to be more candy</td><td><p>Candy is:</p><ul><li>Delicious</li><li>Shiny</li><li>Good for my teeth</li></ul></td></tr></tbody></table>
    HTML

    markup = <<~MARKUP
      |As a...|I would like...|Because...|
      |Student
      or
      \\\\
      Teacher|There to be more candy|Candy is:
      \\\\
      * Delicious
      * Shiny
      * Good for my teeth|
    MARKUP

    expect(html).to match_markup(markup)
  end
  
   it "should handle table empty cells" do
    html = <<~HTML
      <table class="mce-item-table"><tbody><tr><td><p><br data-mce-bogus="1"></p></td><td>Empty</td><td><p><br data-mce-bogus="1"></p></td></tr></tbody></table>
    HTML

    markup = <<~MARKUP
      | |Empty| |
    MARKUP

    expect(html).to match_markup(markup)
  end
  
   it "should handle pre in table empty cells" do
    html = <<~HTML
      <table><tbody><tr><td><pre>a</pre></td><td>d</td></tr><tr><td><pre>b</pre></td><td>c</td></tr></tbody></table>
    HTML

    markup = <<~MARKUP
      |{noformat}
      a{noformat} |d |
      |{noformat}
      b{noformat} |c |
    MARKUP

    expect(html).to match_markup(markup)
  end
  
   it "should handle pre in table" do
    html = <<~HTML
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
    HTML

    markup = <<~MARKUP
      |A |{{B}} |C | 
      |1 |{noformat}
      2{noformat} |3  |
    MARKUP

    expect(html).to match_markup(markup)
  end
  
end
