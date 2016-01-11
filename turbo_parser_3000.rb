require_relative 'github_crawler'
require_relative 'github_auth'

require 'colorize'
require 'io/console'

include TurboParser3000

def empty_line
  puts
end

# enabled echo back
def read_data(type)
  print "#{type.capitalize}: "
  gets.chomp
end

# disabled echo back
def read_password
  print 'Password: '
  STDIN.noecho(&:gets).chomp
end

puts 'Please authenticate with GitHub.'

client = nil
while client.nil?
  username = read_data('username')
  password = read_password
  empty_line
  client = GitHubAuth.new(username, password).client
end
puts 'Successful authentication!'.green
empty_line

while (lines_to_parse = read_data('lines to parse')) !~ /^\d+$/
  puts 'Please enter an integer numeric value.'.red
end

while (language = read_data('language')) !~ /(ruby|java|c\+\+)/i
  puts 'Please choose between C++, Java and Ruby.'.red
end

empty_line

crawler = GitHubCrawler.new(client, language, lines_to_parse)

puts 'OK! Beginning.'.light_blue
crawler.crawl
