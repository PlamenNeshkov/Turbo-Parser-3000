require_relative 'github_parser'

parser = GitHubParser.new("Java", 3000000)
parser.parse_page(1)
