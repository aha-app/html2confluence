require 'html2confluence'

if ARGV.empty?
  puts "Error: Pass HTML file as first argument"
  exit 1
end

file = File.open(ARGV[0])
parser = HTMLToConfluenceParser.new
parser.feed(file.read)
puts parser.to_wiki_markup
