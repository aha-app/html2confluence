class Walker
  
  NBSP = (0xC2.chr + 0xA0.chr).force_encoding(Encoding::UTF_8).freeze
  HORIZONTAL_SPACE = /[\t\p{Zs}]/
  
  def initialize(html)
    @source = html
    @parsed = Nokogiri::HTML.fragment(@source)
  end
  
  def convert
    cleanup @parsed.accept(self)
  end
  
  def cleanup(string)
    # string.gsub(/\n+/, "\n").gsub(/#{HORIZONTAL_SPACE}+/, ' ')
    string
      .gsub(/\n+/, "\n")
      .gsub(/#{HORIZONTAL_SPACE}+/, ' ')
      .gsub(NBSP, ' ')
      .gsub("\r", "\n")
  end
  
  def visit(node)
    send(:"handle_#{node.name}", node)
  end
  
  def handle(nodes)
    Array(nodes).reject do |node|
      node.text? and node.content.gsub(/[\s\n]+/, '').empty?
    end.map do |node|
      visit node
    end.flatten.join
  end
  
  def respond_to_missing?(method)
    method.starts_with?(:handle_) or super
  end
  
  def method_missing(method, *args, &block)
    if method.to_s.start_with?("handle_") and args.length == 1
      node, *_ = args
      if node.text?
        node.content
      else
        handle node.children
      end
    else; super; end
  end
  
# Node handlers

  def handle_#document-fragment(node)
    handle(node.children)
  end

  FORMAT_TAGS = {
    [:b, :strong] => '*', 
    [:i, :em] => '_',
    [:del, :strike] => '-',
    [:u, :ins] => '+',
    cite: '??', 
    sup: '^',
    sub: '~'
  }
  
  FORMAT_TAGS.each do |tags, markup|
    Array(tags).each do |tag|
      define_method :"handle_#{tag}" do |node|
        start = if not node.previous or node.previous.name == "br" or (node.previous.text? and node.previous.content =~ /\W\Z/)
          markup
        else
          ["{", markup, "}"]
        end
        close = if not node.next or node.next.name == "br" or (node.next.text? and node.next.content =~ /\A\W/)
          markup
        else
          ["{", markup, "}"]
        end
        [start, handle(node.children), close]
      end
    end
  end
  
  BLOCK_TAGS = (1..6).map{|n| "h{n}"} << "bq"
  
  BLOCK_TAGS.each do |tag|
    define_method :"handle_#{tag}" do |node|
      ["\n\n", tag, ".", " ", handle(node.children), "\n\n"]
    end
  end
  
  CONTENT_TAGS = [:p, :div]
  
  CONTENT_TAGS.each do |tag|
    define_method :"handle_#{tag}" do |node|
      # ["\n\n", handle(node.children), "\n\n"]
      [handle(node.children), "\n"]
    end
  end
  
  LIST_TAGS = [:ul, :ol]
  
  LIST_TAGS.each do |tag|
    define_method :"handle_#{tag}" do |node|
      [handle(node.children), "\n"]
    end
  end
  
  def handle_li(node)
    list = node.ancestors.find do |parent|
      ["ol", "ul"].include? parent.name
    end
    bullet = if list&.name == "ol"
      "#"
    elsif list&.attr("type") == "square"
      "-"
    else
      "*"
    end
    [bullet, " ", handle(node.children), "\n"]
  end
  
  def handle_table(node)
    ["\n", handle(node.children), "\n"]
  end
  
  def handle_thead(node)
    handle(node.children)
  end
  
  def handle_tbody(node)
    handle(node.children)
  end
  
  def handle_tfooter(node)
    handle(node.children)
  end
  
  def handle_tr(node)
    table_segment = node.ancestors.find do |parent|
      ["thead", "tbody", "tfooter"].include? parent.name
    end
    has_header = node.elements.map(&:name).uniq.include? "th"
    seperator = (table_segment&.name == "thead" or has_header) ? "||" : "|"
    [seperator, handle(node.children), "\n"]
  end
  
  def handle_th(node)
    [handle(node.children).strip, " ", "||"]
  end
  
  def handle_td(node)
    [handle(node.children).strip, " ", "|"]
  end
  
  def handle_blockquote(node)
    shorthand = catch(:shorthand) do
      node.traverse do |child|
        next if child == node
        # Check for multiline blockquotes
        if child.text? and child.content =~ /\n/
          throw :shorthand, false
        end
        # Check for nested blockquotes
        if child.name == "blockquote"
          throw :shorthand, false
        end
      end
      throw :shorthand, true
    end
    
    if shorthand
      ["bq.", " ", handle(node.children)]
    else
      ["\n", "{quote}", "\n", handle(node.children), "\n", "{quote}"]
    end
  end
  
  def handle_code(node)
    ["{code}", handle(node.children), "{code}"]
  end
  
  def handle_pre(node)
    ["{noformat}", handle(node.children), "{noformat}"]
  end
  
  def handle_a(node)
    link = node["href"].to_s[1..-1]
    link = ["|", link] if link
    ["[", handle(node.children), link, "]", " "]
  end
  
  def handle_font(node)
    ["{color:#{node["color"]}}", handle(node.children), "{color}"]
  end
  
  EMOJI = {
    smile: ":)",
    sad: ":(",
    tongue: ":P",
    biggrin: ":D",
    wink: ";)",
    thumbs_up: "(y)",
    thumbs_down: "(n)",
    information: "(i)",
    check: "(/)",
    error: "(x)",
    warning: "(!)",
    add: "(+)",
    forbidden: "(-)",
    help_16: "(?)",
    lightbulb_on: "(on)",
    lightbulb: "(off)",
    star_yellow: "(*)",
    star_red: "(*r)",
    star_green: "(*g)",
    star_blue: "(*b)",
    star_yellow: "(*y)",
  }
  EMOJI_SRC = /([\w.-_:\/]+|\/)images\/icons\/emoticons\/(?<emoji>#{EMOJI.keys.map(&:to_s).join("|")})\.(gif|png)/
  
  def handle_img(node)
    if src = node["src"]
      if emoji = src[EMOJI_SRC, "emoji"]
        EMOJI[emoji.to_sym]
      else
        [" ", "!", src, "!", " "]
      end
    end
  end
  
  def handle_caption(node)
    ["\n", handle(node.children), "\n"]
  end
  
  def handle_tt(node)
    ["{{", handle(node.children), "}}"]
  end
  
  def handle_br(node)
    ["\r"]
  end
  
  def handle_hr(node)
    ["----"]
  end
end
