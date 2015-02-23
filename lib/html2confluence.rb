require 'rexml/document'

# A class to convert HTML to textile. Based on the python parser
# found at http://aftnn.org/content/code/html2textile/
#
# Read more at http://jystewart.net/process/2007/11/converting-html-to-textile-with-ruby
#
# Author::    James Stewart  (mailto:james@jystewart.net)
# Copyright:: Copyright (c) 2007 James Stewart
# License::   Distributes under the same terms as Ruby

# This class is an implementation of an SGMLParser designed to convert
# HTML to textile.
# 
# Example usage:
#   parser = HTMLToTextileParser.new
#   parser.feed(input_html)
#   puts parser.to_textile
class HTMLToConfluenceParser
  
  attr_accessor :result
  attr_accessor :data_stack
  attr_accessor :a_href
  attr_accessor :a_title
  attr_accessor :list_stack
  
  def initialize(verbose=nil)
    @output = String.new
    @stack = []
    @preserveWhitespace = false
    @last_write = ""
    @tableHeaderRow = false
    self.result = []
    self.data_stack = []
    self.list_stack = []
  end
  
  # Normalise space in the same manner as HTML. Any substring of multiple
  # whitespace characters will be replaced with a single space char.
  def normalise_space(s)
    return s if @preserveWhitespace
    s.to_s.gsub(/\s+/x, ' ')
  end
  
  # Escape any special characters.
  def escape_special_characters(s)
    return s
    # Escaping is disabled now since it caused more problems that not having 
    # it. The insertion of unecessary escaping was annoying for JIRA users.
    s.to_s.gsub(/[*#+\-_{}|]/) do |s|
      "\\#{s}"
    end
  end
  
  def make_block_start_pair(tag, attributes)
    if tag == 'p'
      # don't markup paragraphs explicitly unless necessary (i.e. there are id or class attributes)
      write("\n\n")
    else
      write("\n\n#{tag}. ")
    end
    start_capture(tag)
  end
  
  def make_block_end_pair
    stop_capture_and_write
    write("\n\n")
  end
  
  def make_quicktag_start_pair(tag, wrapchar, attributes)
    @skip_quicktag = ( tag == 'span')
    start_capture(tag)
  end

  def make_quicktag_end_pair(wrapchar)
    content = stop_capture
    
    # Don't make quicktags with empty content. 
    if content.join("").strip.empty?
      write(content)
      return
    end
    
    unless @skip_quicktag
      unless in_nested_quicktag?
        #write([" "]) 
      end
      write(["#{wrapchar}"])
    end
    write(content)
    write([wrapchar]) unless @skip_quicktag
    unless in_nested_quicktag?
      #write([" "]) 
    end
  end
  
  def in_nested_quicktag?
    @quicktags ||= QUICKTAGS.keys
    @stack.size > 1 && @quicktags.include?(@stack[@stack.size-1]) && @quicktags.include?(@stack[@stack.size-2])
  end
  
  def write(d)
    @last_write = Array(d).join("")
    if self.data_stack.size < 2
      self.result += Array(d)
    else
      self.data_stack[-1] += Array(d)
    end
  end
          
  def start_capture(tag)
    self.data_stack.push([])
  end
  
  def stop_capture
    self.data_stack.pop
  end
  
  def stop_capture_and_write
    self.write(self.data_stack.pop)
  end

  def handle_data(data)
    if @preserveWhitespace
      write(data)
    else
      data ||= ""
      data = normalise_space(escape_special_characters(data))
      if @last_write[-1] =~ /\s/
        data = data.lstrip # Collapse whitespace if the previous character was whitespace.
      end
        
      write(data)
    end
  end

  %w[1 2 3 4 5 6].each do |num|
    define_method "start_h#{num}" do |attributes|
      make_block_start_pair("h#{num}", attributes)
    end
    
    define_method "end_h#{num}" do
      make_block_end_pair
    end
  end

  PAIRS = { 'bq' => 'bq', 'p' => 'p' }
  QUICKTAGS = { 'b' => '*', 'strong' => '*', 'del' => '-',
    'i' => '_', 'ins' => '+', 'u' => '+', 'em' => '_', 'cite' => '??', 
    'sup' => '^', 'sub' => '~', 'code' => '@', 'span' => '%'}
  
  PAIRS.each do |key, value|
    define_method "start_#{key}" do |attributes|
      make_block_start_pair(value, attributes)
    end
    
    define_method "end_#{key}" do
      make_block_end_pair
    end
  end
  
  QUICKTAGS.each do |key, value|
    define_method "start_#{key}" do |attributes|
      make_quicktag_start_pair(key, value, attributes)
    end
    
    define_method "end_#{key}" do
      make_quicktag_end_pair(value)
    end
  end
  
  def start_div(attrs)
    write("\n\n")
    start_capture("div")
  end
  
  def end_div
    stop_capture_and_write
    write("\n\n")
  end  
  
  def start_tt(attrs)
    write("{{")
  end
  
  def end_tt
    write("}}")
  end
  
  def start_ol(attrs)
    self.list_stack.push :ol
  end

  def end_ol
    self.list_stack.pop
    if self.list_stack.empty?
      write("\n")
    end
  end

  def start_ul(attrs)
    if attrs['type'] == "square"
      self.list_stack.push :ul_square
    else
      self.list_stack.push :ul
    end
  end

  def end_ul
    self.list_stack.pop
    if self.list_stack.empty?
      write("\n")
    end
  end
  
  def start_li(attrs)
    write("\n")
    write(self.list_stack.collect {|s| 
        case s
        when :ol then "#"
        when :ul then "*"
        when :ul_square then "-" 
        end 
      }.join(""))
    write(" ")
    start_capture("li")
  end

  def end_li
    stop_capture_and_write
  end

  def start_a(attrs)
    self.a_href = attrs['href']
    self.a_title = attrs['title']
    if self.a_href
      write("[")
      start_capture("a")
    end
  end

  def end_a
    if self.a_href
      content = stop_capture
      if self.a_href.gsub(/^#/, "") == content.join("")
        write([self.a_href, "] "])
      else
        write(content)
        write(["|", self.a_href, "] "])
      end

      self.a_href = self.a_title = false
    end
  end
  
  def start_font(attrs)
    color = attrs['color']
    write("{color:#{color}}")
  end
  
  def end_font
    write("{color}")
  end

  def start_img(attrs)
    write([" !", attrs["src"], "! "])
  end
  
  def end_img
  end

  def start_table(attrs)
   write("\n\n")
 end
 
  def end_table
   write("\n\n")
  end 

  def start_caption(attrs)
   write("\n")
 end
 
  def end_caption
   write("\n")
  end 

  def start_tr(attrs)
    write("\n")
  end

  def end_tr
    if @tableHeaderRow
      write("||")
    else
      write("|")
    end
  end
  
  def start_th(attrs)
    write("||")
    start_capture("th")
    @tableHeaderRow = true
  end

  def end_th
    s = stop_capture
    write(cleanup_table_cell(s))
  end  

  def start_td(attrs)
    write("|")
    start_capture("td")
    @tableHeaderRow = false
  end

  def end_td
    s = stop_capture
    write(cleanup_table_cell(s))
  end
  
  def cleanup_table_cell(s)
    clean_content = s.join("").strip.gsub(/\n{2,}/, "\n" + '\\\\\\' + "\n")
    # Don't allow a completely empty cell because that will look like a header.
    clean_content = " " if clean_content.empty?
    [clean_content]
  end

  def start_br(attrs)
    write("\n")
  end
  
  def start_hr(attrs)
    write("---")
  end
  
  def start_blockquote(attrs)
    start_capture("blockquote")
  end

  def end_blockquote
    s = stop_capture
    contains_newline = s.detect do |phrase|
      phrase =~ /\n/ or phrase == "bq. "
    end
    
    if contains_newline
      write("\n{quote}\n")
      write(s)
      write("\n{quote}")
    else
      write("bq. ")
      write(s)
    end
  end
  
  def start_pre(attrs)
    @preserveWhitespace = true
    write("{noformat}\n")
  end

  def end_pre
    stop_capture_and_write
    write("\n{noformat}")
    @preserveWhitespace = false
  end
  
  def preprocess(data)
    # clean up leading and trailing spaces within phrase modifier tags
    quicktags_for_re = QUICKTAGS.keys.uniq.join('|')
    leading_spaces_re = /(<(?:#{quicktags_for_re})(?:\s+[^>]*)?>)( +|<br\s*\/?>)/
    tailing_spaces_re = /( +|<br\s*\/?>)(<\/(?:#{quicktags_for_re})(?:\s+[^>]*)?>)/
    while data =~ leading_spaces_re
      data.gsub!(leading_spaces_re,'\2\1')
    end
    while data =~ tailing_spaces_re
      data.gsub!(tailing_spaces_re,'\2\1')
    end
    # replace non-breaking spaces
    data.gsub!(/&(nbsp|#160);/,' ')
    # replace special entities.
    data.gsub!(/&(mdash|#8212);/,'---')
    data.gsub!(/&(ndash|#8211);/,'--')
    
    # remove empty blockquotes and list items (other empty elements are easy enough to deal with)
    data.gsub!(/<blockquote>\s*(<br[^>]*>)?\s*<\/blockquote>/x,' ')
    
    # Fix unclosed <br>
    data.gsub!(/<br[^>]*>/, "<br/>")

    # Remove <wbr>
    data.gsub!(/<wbr[^>]*>/, "")
    
    # Fix unclosed <img>
    data.gsub!(/(<img[^>]+)(?<!\/)>/, '\1 />')
    
    data
  end
  
  # Return the textile after processing
  def to_wiki_markup
    fix_textile_whitespace!(result.join)
  end
  
  def fix_textile_whitespace!(output)
    # fixes multiple blank lines, blockquote indicator followed by blank lines, and trailing whitespace after quicktags
    # modifies input string and also returns it
    output.gsub!(/(\n\s*){2,}/,"\n\n")
    output.gsub!(/bq. \n+(\w)/,'bq. \1')
    QUICKTAGS.values.uniq.each do |t|
      output.gsub!(/ #{Regexp.escape(t)}[ \t]+#{Regexp.escape(t)} /,' ') # removes empty quicktags
      #output.gsub!(/(\[?#{Regexp.escape(t)})(\w+)([^#{Regexp.escape(t)}]+)(\s+)(#{Regexp.escape(t)}\]?)/,'\1\2\3\5\4') # fixes trailing whitespace before closing quicktags
    end
    #output.squeeze!(' ')
    #output.gsub!(/^[ \t]/,'') # leading whitespace
    #output.gsub!(/[ \t]$/,'') # trailing whitespace
    output.strip!
    return output
  end
  
  
  def feed(data)
    stream = StringIO.new(preprocess("<div>#{data}</div>"))
    
    REXML::Document.parse_stream(stream, self)
  end
  
  def tag_start(name, attributes = {})
    #puts "<p>Start #{name}</p>"
    @stack.push(name)
    if self.respond_to?("start_#{name}")
      self.send("start_#{name}", attributes)
    end
  end
  
  def tag_end(name)
    #puts "<p>End #{name}</p>"
    if self.respond_to?("end_#{name}")
      self.send("end_#{name}")
    end
    @stack.pop
  end
  
  def text(string)
    handle_data(string)
  end
end
