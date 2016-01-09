require 'octokit'
require 'fileutils'
require 'csv'
require_relative 'repository_parser'

class GitHubCrawler
  def initialize(language, lines_to_parse)
    @language = language.downcase
    @lines_to_parse = lines_to_parse

    clean_old_result

    login = 'TuesTpProject'
    password = 'random98'

    @client = Octokit::Client.new(login: login, password: password)

    puts 'Successful authentication with GitHub!'
  end

  def clean_old_result
    FileUtils.rm_rf(Dir.glob('tmp/**/*'))
    FileUtils.rm_rf(Dir.glob('result/**/*'))
  end

  def print_divider
    puts '-' * 80
  end

  def log_repo(repo)
    CSV.open('result/repositories.csv', 'a') do |csv|
      row = []
      row << repo.name
      row << repo.html_url
      csv << row
    end
  end

  def parse_page(page_number)
    response = @client.search_repositories("language:#{@language}")

    repos = response.items
    repos.each do |repo|
      print_divider
      puts "Parsing repository #{repo.full_name}"
      ###
      log_repo(repo)
    end
    print_divider
  end
end
