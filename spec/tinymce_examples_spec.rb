require_relative 'spec_helper'

describe HTMLToConfluenceParser, "when consuming TinyMCE generated HTML" do

  context "edge case with nested formats with spans and &nbsp;" do

    it "should handle nested formatting" do
      html = <<~HTML
        test<i>test<b>test</b></i>
      HTML

      markup = <<~MARKUP
        test_test*test*_
      MARKUP

      expect(html).to match_markup(markup)
    end

    it "should handle arbitrary spans" do
      html = <<~HTML
        test<span>test<span>test</span></span>
      HTML

      markup = <<~MARKUP
        testtesttest
      MARKUP

      expect(html).to match_markup(markup)
    end

    it "should handle arbitrary %nbsp;" do
      html = <<~HTML
        test&nbsp;test&nbsp;test
      HTML

      markup = <<~MARKUP
        test test test
      MARKUP

      expect(html).to match_markup(markup)
    end

    it "should handle trailing %nbsp; inside formats" do
      html = <<~HTML
        <b>test&nbsp;</b>
      HTML

      markup = <<~MARKUP
        *test *
      MARKUP

      expect(html).to match_markup(markup)
    end

    it "should handle format-wrapping spans" do
      html = <<~HTML
        <span><b>test</b></span>
      HTML

      markup = <<~MARKUP
        *test*
      MARKUP

      expect(html).to match_markup(markup)
    end

    it "should handle consecutive format-delineated spaces" do
      html = <<~HTML
        <b>test&nbsp;</b> test
      HTML

      markup = <<~MARKUP
        *test * test
      MARKUP

      expect(html).to match_markup(markup)
    end

    it "should handle all these things at once" do
      html = <<~HTML
        test&nbsp;<span><i>test&nbsp;<span><b>test</b></span></i></span>
      HTML

      markup = <<~MARKUP
        test _test *test*_
      MARKUP

      expect(html).to match_markup(markup)
    end

  end

  context "with empty li's" do

    it "should preserve leading empty li's" do
      html = <<~HTML
        <ul>
          <li></li>
          <li>test</li>
          <li>test</li>
        </ul>
      HTML

      markup = "*  \n* test \n* test "

      expect(html).to match_markup(markup)
    end


    it "should preserve inner empty li's" do
      html = <<~HTML
        <ul>
          <li>test</li>
          <li></li>
          <li>test</li>
        </ul>
      HTML

      markup = "* test \n* \n* test "

      expect(html).to match_markup(markup)
    end


    it "should preserve trailing empty li's" do
      html = <<~HTML
        <ul>
          <li>test</li>
          <li>test</li>
          <li></li>
        </ul>
      HTML

      markup = "* test \n* test \n* "

      expect(html).to match_markup(markup)
    end

  end

  context "formatting within tables" do

    it "should normalize spaces around table items to only contain one trailing space" do
      html = <<~HTML
      <table><tbody>
        <tr>
          <th> Header</th>
        </tr>
        <tr>
          <td>text   </td>
        </tr>
      </tbody></table>
      HTML

      markup = <<~HTML
      ||Header ||
      |text |
      HTML

      expect(html).to match_markup(markup)
    end

    it "should handle formatting" do
      html = <<~HTML
      <table><tbody>
        <tr>
          <th>Header</th>
        </tr>
        <tr>
          <td><b>bold</b></td>
        </tr>
      </tbody></table>
      HTML

      markup = <<~HTML
      ||Header ||
      |*bold* |
      HTML

      expect(html).to match_markup(markup)
    end

    it "should handle lists" do
      html = <<~HTML
        <table>
          <tr>
            <th>Header</th>
          </tr>
          <tr>
            <td>
              <ul>
                <li>test</li>
                <li>test</li>
              </ul>
            </td>
          </tr>
        </table>
      HTML

      markup = <<~HTML
      ||Header ||
      |* test
      * test |
      HTML

      expect(html).to match_markup(markup)
    end

    it "should handle empty cells" do
      html = <<~HTML
      <table><tbody>
        <tr>
          <th>Header</th>
        </tr>
        <tr>
          <td></td>
        </tr>
      </tbody></table>
      HTML

      markup = <<~HTML
      ||Header ||
      | |
      HTML

      expect(html).to match_markup(markup)

      html = <<~HTML
      <table><tbody>
        <tr>
          <th>Header</th>
          <th>Header</th>
        </tr>
        <tr>
          <td>text</td>
          <td></td>
        </tr>
      </tbody></table>
      HTML

      markup = <<~HTML
      ||Header ||Header ||
      |text | |
      HTML

      expect(html).to match_markup(markup)

      html = <<~HTML
      <table><tbody>
        <tr>
          <th>Header</th>
          <th>Header</th>
        </tr>
        <tr>
          <td>text</td>
          <td></td>
        </tr>
      </tbody></table>
      HTML

      markup = <<~HTML
      ||Header ||Header ||
      |text | |
      HTML

      expect(html).to match_markup(markup)

      html = <<~HTML
      <table><tbody>
        <tr>
          <th>Header</th>
          <th>Header</th>
        </tr>
        <tr>
          <td></td>
          <td>text</td>
        </tr>
      </tbody></table>
      HTML

      markup = <<~HTML
      ||Header ||Header ||
      | |text |
      HTML

      expect(html).to match_markup(markup)

      html = <<~HTML
      <table><tbody>
        <tr>
          <th>Header</th>
          <th>Header</th>
          <th>Header</th>
        </tr>
        <tr>
          <td>text</td>
          <td></td>
          <td>text</td>
        </tr>
      </tbody></table>
      HTML

      markup = <<~HTML
      ||Header ||Header ||Header ||
      |text | |text |
      HTML

      expect(html).to match_markup(markup)
    end

  end

end
