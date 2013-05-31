require 'sgml_parser'

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
class HTMLToConfluenceParser < SGMLParser
  
  attr_accessor :result
  attr_accessor :in_block
  attr_accessor :data_stack
  attr_accessor :a_href
  attr_accessor :a_title
  attr_accessor :in_ul
  attr_accessor :in_ol
  
  @@permitted_tags = []
  @@permitted_attributes = []
  
  Entitydefs = {
    'Aacute' => 193,
    'aacute' => 225,
    'Acirc' => 194,
    'acirc' => 226,
    'acute' => 180,
    'AElig' => 198,
    'aelig' => 230,
    'Agrave' => 192,
    'agrave' => 224,
    'alefsym' => 8501,
    'Alpha' => 913,
    'alpha' => 945,
    'amp' => 38,
    'and' => 8743,
    'ang' => 8736,
    'apos' => 39,
    'Aring' => 197,
    'aring' => 229,
    'asymp' => 8776,
    'Atilde' => 195,
    'atilde' => 227,
    'Auml' => 196,
    'auml' => 228,
    'bdquo' => 8222,
    'Beta' => 914,
    'beta' => 946,
    'brvbar' => 166,
    'bull' => 8226,
    'cap' => 8745,
    'Ccedil' => 199,
    'ccedil' => 231,
    'cedil' => 184,
    'cent' => 162,
    'Chi' => 935,
    'chi' => 967,
    'circ' => 710,
    'clubs' => 9827,
    'cong' => 8773,
    'copy' => 169,
    'crarr' => 8629,
    'cup' => 8746,
    'curren' => 164,
    'Dagger' => 8225,
    'dagger' => 8224,
    'dArr' => 8659,
    'darr' => 8595,
    'deg' => 176,
    'Delta' => 916,
    'delta' => 948,
    'diams' => 9830,
    'divide' => 247,
    'Eacute' => 201,
    'eacute' => 233,
    'Ecirc' => 202,
    'ecirc' => 234,
    'Egrave' => 200,
    'egrave' => 232,
    'empty' => 8709,
    'emsp' => 8195,
    'ensp' => 8194,
    'Epsilon' => 917,
    'epsilon' => 949,
    'equiv' => 8801,
    'Eta' => 919,
    'eta' => 951,
    'ETH' => 208,
    'eth' => 240,
    'Euml' => 203,
    'euml' => 235,
    'euro' => 8364,
    'exist' => 8707,
    'fnof' => 402,
    'forall' => 8704,
    'frac12' => 189,
    'frac14' => 188,
    'frac34' => 190,
    'frasl' => 8260,
    'Gamma' => 915,
    'gamma' => 947,
    'ge' => 8805,
    'gt' => 62,
    'hArr' => 8660,
    'harr' => 8596,
    'hearts' => 9829,
    'hellip' => 8230,
    'Iacute' => 205,
    'iacute' => 237,
    'Icirc' => 206,
    'icirc' => 238,
    'iexcl' => 161,
    'Igrave' => 204,
    'igrave' => 236,
    'image' => 8465,
    'infin' => 8734,
    'int' => 8747,
    'Iota' => 921,
    'iota' => 953,
    'iquest' => 191,
    'isin' => 8712,
    'Iuml' => 207,
    'iuml' => 239,
    'Kappa' => 922,
    'kappa' => 954,
    'Lambda' => 923,
    'lambda' => 955,
    'lang' => 9001,
    'laquo' => 171,
    'lArr' => 8656,
    'larr' => 8592,
    'lceil' => 8968,
    'ldquo' => 8220,
    'le' => 8804,
    'lfloor' => 8970,
    'lowast' => 8727,
    'loz' => 9674,
    'lrm' => 8206,
    'lsaquo' => 8249,
    'lsquo' => 8216,
    'lt' => 60,
    'macr' => 175,
    'mdash' => 8212,
    'micro' => 181,
    'middot' => 183,
    'minus' => 8722,
    'Mu' => 924,
    'mu' => 956,
    'nabla' => 8711,
    'nbsp' => 160,
    'ndash' => 8211,
    'ne' => 8800,
    'ni' => 8715,
    'not' => 172,
    'notin' => 8713,
    'nsub' => 8836,
    'Ntilde' => 209,
    'ntilde' => 241,
    'Nu' => 925,
    'nu' => 957,
    'Oacute' => 211,
    'oacute' => 243,
    'Ocirc' => 212,
    'ocirc' => 244,
    'OElig' => 338,
    'oelig' => 339,
    'Ograve' => 210,
    'ograve' => 242,
    'oline' => 8254,
    'Omega' => 937,
    'omega' => 969,
    'Omicron' => 927,
    'omicron' => 959,
    'oplus' => 8853,
    'or' => 8744,
    'ordf' => 170,
    'ordm' => 186,
    'Oslash' => 216,
    'oslash' => 248,
    'Otilde' => 213,
    'otilde' => 245,
    'otimes' => 8855,
    'Ouml' => 214,
    'ouml' => 246,
    'para' => 182,
    'part' => 8706,
    'permil' => 8240,
    'perp' => 8869,
    'Phi' => 934,
    'phi' => 966,
    'Pi' => 928,
    'pi' => 960,
    'piv' => 982,
    'plusmn' => 177,
    'pound' => 163,
    'Prime' => 8243,
    'prime' => 8242,
    'prod' => 8719,
    'prop' => 8733,
    'Psi' => 936,
    'psi' => 968,
    'quot' => 34,
    'radic' => 8730,
    'rang' => 9002,
    'raquo' => 187,
    'rArr' => 8658,
    'rarr' => 8594,
    'rceil' => 8969,
    'rdquo' => 8221,
    'real' => 8476,
    'reg' => 174,
    'rfloor' => 8971,
    'Rho' => 929,
    'rho' => 961,
    'rlm' => 8207,
    'rsaquo' => 8250,
    'rsquo' => 8217,
    'sbquo' => 8218,
    'Scaron' => 352,
    'scaron' => 353,
    'sdot' => 8901,
    'sect' => 167,
    'shy' => 173,
    'Sigma' => 931,
    'sigma' => 963,
    'sigmaf' => 962,
    'sim' => 8764,
    'spades' => 9824,
    'sub' => 8834,
    'sube' => 8838,
    'sum' => 8721,
    'sup' => 8835,
    'sup1' => 185,
    'sup2' => 178,
    'sup3' => 179,
    'supe' => 8839,
    'szlig' => 223,
    'Tau' => 932,
    'tau' => 964,
    'there4' => 8756,
    'Theta' => 920,
    'theta' => 952,
    'thetasym' => 977,
    'thinsp' => 8201,
    'THORN' => 222,
    'thorn' => 254,
    'tilde' => 732,
    'times' => 215,
    'trade' => 8482,
    'Uacute' => 218,
    'uacute' => 250,
    'uArr' => 8657,
    'uarr' => 8593,
    'Ucirc' => 219,
    'ucirc' => 251,
    'Ugrave' => 217,
    'ugrave' => 249,
    'uml' => 168,
    'upsih' => 978,
    'Upsilon' => 933,
    'upsilon' => 965,
    'Uuml' => 220,
    'uuml' => 252,
    'weierp' => 8472,
    'Xi' => 926,
    'xi' => 958,
    'Yacute' => 221,
    'yacute' => 253,
    'yen' => 165,
    'Yuml' => 376,
    'yuml' => 255,
    'Zeta' => 918,
    'zeta' => 950,
    'zwj' => 8205,
    'zwnj' => 8204
  }  
  
  def initialize(verbose=nil)
    @output = String.new
    self.in_block = false
    self.result = []
    self.data_stack = []
    super(verbose)
  end
  
  # Normalise space in the same manner as HTML. Any substring of multiple
  # whitespace characters will be replaced with a single space char.
  def normalise_space(s)
    s.to_s.gsub(/\s+/x, ' ')
  end
  
  def build_styles_ids_and_classes(attributes)
    idclass = ''
    idclass += attributes['class'] if attributes.has_key?('class')
    idclass += "\##{attributes['id']}" if attributes.has_key?('id')
    idclass = "(#{idclass})" if idclass != ''
    
    style = attributes.has_key?('style') ? "{#{attributes['style']}}" : ""
    "#{idclass}#{style}"
  end
  
  def make_block_start_pair(tag, attributes)
    attributes = attrs_to_hash(attributes)
    class_style = build_styles_ids_and_classes(attributes)
    if tag == 'p' && class_style.length == 0
      # don't markup paragraphs explicitly unless necessary (i.e. there are id or class attributes)
      write("\n\n")
    else
      write("\n\n#{tag}#{class_style}. ")
    end
    start_capture(tag)
  end
  
  def make_block_end_pair
    stop_capture_and_write
    write("\n\n")
  end
  
  def make_quicktag_start_pair(tag, wrapchar, attributes)
    attributes = attrs_to_hash(attributes)
    class_style = build_styles_ids_and_classes(attributes)
    @skip_quicktag = ( tag == 'span' && class_style.length == 0 )
    # use square brackets for superscript and subscript to avoid whitespace issues
    # this may be RedCloth specific, but as it's the de facto standard textile library for Ruby, should be ok
    @use_square_brackets = ( !@stack.empty? && %w{ sub sup }.include?(@stack[@stack.size-1]) )
    unless @skip_quicktag
      unless in_nested_quicktag?
        @use_square_brackets ? write(["["]) : write([" "]) 
      end
      write(["#{wrapchar}#{class_style}"])
    end
    start_capture(tag)
  end

  def make_quicktag_end_pair(wrapchar)
    stop_capture_and_write
    write([wrapchar]) unless @skip_quicktag
    unless in_nested_quicktag?
      @use_square_brackets ? write(["]"]) : write([" "]) 
    end
  end
  
  def in_nested_quicktag?
    @quicktags ||= QUICKTAGS.keys
    @stack.size > 1 && @quicktags.include?(@stack[@stack.size-1]) && @quicktags.include?(@stack[@stack.size-2])
  end
  
  def write(d)
    if self.data_stack.size < 2
      self.result += Array(d)
    else
      self.data_stack[-1] += Array(d)
    end
  end
          
  def start_capture(tag)
    self.in_block = tag
    self.data_stack.push([])
  end
  
  def stop_capture_and_write
    self.in_block = false
    self.write(self.data_stack.pop)
  end

  def handle_data(data)
    write(normalise_space(data).lstrip) unless data.nil? or data == ''
  end

  %w[1 2 3 4 5 6].each do |num|
    define_method "start_h#{num}" do |attributes|
      make_block_start_pair("h#{num}", attributes)
    end
    
    define_method "end_h#{num}" do
      make_block_end_pair
    end
  end

  PAIRS = { 'blockquote' => 'bq', 'p' => 'p' }
  QUICKTAGS = { 'b' => '*', 'strong' => '*', 
    'i' => '_', 'em' => '_', 'cite' => '??', 's' => '-', 
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
  
  def start_ol(attrs)
    self.in_ol = true
    write("\n\n")
  end

  def end_ol
    self.in_ol = false
    write("\n")
  end

  def start_ul(attrs)
    self.in_ul = true
    write("\n\n")
  end

  def end_ul
    self.in_ul = false
    write("\n")
  end
  
  def start_li(attrs)
    if self.in_ol
      write("# ")
    else
      write("* ")
    end
    start_capture("li")
  end

  def end_li
    stop_capture_and_write
    write("\n")
  end

  def start_a(attrs)
    attrs = attrs_to_hash(attrs)
    self.a_href = attrs['href']
    self.a_title = attrs['title']
    if self.a_href
      write(" \"")
      write('(' + attrs['class'] + ')') if attrs['class']
      start_capture("a")
    end
  end

  def end_a
    if self.a_href
      stop_capture_and_write
      write('(' + self.a_title + ')') if self.a_title
      write(["\":", self.a_href, " "])

      self.a_href = self.a_title = false
    end
  end

  def attrs_to_hash(array)
    array.inject({}) { |collection, part| collection[part[0].downcase] = part[1]; collection }
  end

  def start_img(attrs)
    attrs = attrs_to_hash(attrs)
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
    write("|")
  end
  
  def start_th(attrs)
    write("|")
    start_capture("th")
  end

  def end_th
    stop_capture_and_write
  end  

  def start_td(attrs)
    write("|")
    start_capture("td")
  end

  def end_td
    stop_capture_and_write
  end

  def start_br(attrs)
    write("\n")
  end
  
  def unknown_starttag(tag, attrs)
    if @@permitted_tags.include?(tag)
      write(["<", tag])
      attrs.each do |key, value|
        if @@permitted_attributes.include?(key)
          write([" ", key, "=\"", value, "\""])
        end
      end
      write(">")
    end
  end
            
  def unknown_endtag(tag)
    if @@permitted_tags.include?(tag)
      write(["</", tag, ">"])
    end
  end
  
  def feed(data)
    # pre-process input before feeding to the sgml parser (some things are difficult to parse)
    # can't handle paragraphs nested within blockquotes, turn them into multiple blockquotes
    data.gsub!(/<blockquote>((\s*<p[^>]*>.*<\/p>\s*){1,})<\/blockquote>/xi) do |m|
      $1.strip.gsub(/<(\/?)p([^>]*)>/i,'<\1blockquote\2>')
    end
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
    # remove empty blockquotes and list items (other empty elements are easy enough to deal with)
    data.gsub!(/<blockquote>\s*(<br[^>]*>)?\s*<\/blockquote>/x,' ')
    data.gsub!(/<li>\s*(<br[^>]*>)?\s*<\/li>/x,'')
    super(data)
  end
  
  # Return the textile after processing
  def to_wiki_markup
    fix_textile_whitespace!(result.join)
  end
  
  def handle_charref(charref)
    write([charref.to_i].pack('U'))
  end
  
  def handle_entityref(entityref)
    if Entitydefs.include?(entityref)
      write([Entitydefs[entityref]].pack('U'))
    else
      write('['+entityref+']')
    end
  end
  
  def handle_whitespace(data)
    write(normalise_space(data)) unless data.nil? or data == ''
  end
  
  def fix_textile_whitespace!(output)
    # fixes multiple blank lines, blockquote indicator followed by blank lines, and trailing whitespace after quicktags
    # modifies input string and also returns it
    output.gsub!(/(\n\s*){2,}/,"\n\n")
    output.gsub!(/bq. \n+(\w)/,'bq. \1')
    QUICKTAGS.values.uniq.each do |t|
      output.gsub!(/ #{Regexp.escape(t)}\s+#{Regexp.escape(t)} /,' ') # removes empty quicktags
      output.gsub!(/(\[?#{Regexp.escape(t)})(\w+)([^#{Regexp.escape(t)}]+)(\s+)(#{Regexp.escape(t)}\]?)/,'\1\2\3\5\4') # fixes trailing whitespace before closing quicktags
    end
    output.squeeze!(' ')
    output.gsub!(/^[ \t]/,'') # leading whitespace
    output.gsub!(/[ \t]$/,'') # trailing whitespace
    output.strip!
    return output
  end
  
  # UNCONVERTED PYTHON METHODS
  #
  # def handle_starttag(self, tag, method, attrs):
  #     method(dict(attrs))
  #     
  
end
