# HTML2Confluence #

A quick and simple way to convert HTML to Confluence Wiki Markup, based on
html2textile.

    parser = HTMLToConfluenceParser.new
    parser.feed(your_html)
    puts parser.to_wiki_markup

There are some JIRA/Confluence markup that we do not support:

* The [mailto:] tag.
* The {anchor:} tag.


## Installation ##

    $ gem build html2confluence.gemspec
    $ gem install html2confluence-1.3.18.gem

## Command line usage ##

    $ ruby convert.rb /path/to/file.html
