require_relative 'github_crawler'

parser = GitHubCrawler.new("Java", 3000000)
parser.parse_page(1)
