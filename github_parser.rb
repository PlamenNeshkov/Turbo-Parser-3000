require 'octokit'
require 'fileutils'
require 'csv'

class GitHubParser
  def initialize(language, lines_to_parse)
    @language = language
    @lines_to_parse = lines_to_parse

    clean_old_result

    login = 'TuesTpProject'
    password = 'random98'

    @client = Octokit::Client.new(login: 'TuesTpProject', password: 'random98')
    # while client.user == nil
    #   client = Octokit::Client.new(login: 'TuesTpProject', password: 'random98')
    # end

    puts "Successful authentication with GitHub!"
  end

  def clean_old_result
    FileUtils.rm_rf(Dir.glob('result/*'))
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

  def parse_repo(repo)
    FileUtils.cd('tmp')
    `git clone #{repo.clone_url}`
    FileUtils.cd('..')
  end

  def parse_page(page_number)
    response = @client.search_repositories("language:#{@language.downcase}")

    repos = response.items
    repos.each do |repo|
      print_divider
      puts "Parsing repository #{repo.full_name}"
      parse_repo(repo)
      log_repo(repo)
    end
    print_divider
  end
end
