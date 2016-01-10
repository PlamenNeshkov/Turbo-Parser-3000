require_relative 'github_crawler'

include TurboParser3000

crawler = GitHubCrawler.new('C++', 1_000_000)
crawler.crawl
