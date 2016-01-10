require 'octokit'
require 'fileutils'
require 'csv'
require_relative 'repository_parser'

module TurboParser3000
  class GitHubCrawler
    def initialize(language, lines_to_parse)
      @language = language.downcase
      @lines_to_parse = lines_to_parse
      @lines_parsed = 0

      clean_old_result

      login = 'TuesTpProject'
      password = 'random98'

      @client = Octokit::Client.new(login: login, password: password)
      puts 'Successful authentication with GitHub!'

      @repo_parser = RepositoryParser.new(@language)
      @result = Result.new
    end

    def crawl
      page_number = 1

      while @lines_parsed < @lines_to_parse
        parse_page(page_number)
        page_number += 1
      end
    end

    def clean_old_result
      FileUtils.rm_rf(Dir.glob('tmp/**/*'))
      FileUtils.rm_rf(Dir.glob('result/**/*'))
    end

    def print_divider
      puts '-' * 80
    end

    def log_repo(repo, lines_parsed)
      CSV.open('result/repositories.csv', 'a') do |csv|
        row = []
        row << repo.name
        row << repo.html_url
        row << lines_parsed
        csv << row
      end
    end

    def write_result(repo_result)
      @result.merge(repo_result)
      @result.sort!
      @result.to_json(@language)
    end

    def handle_repo(repo)
      print_divider

      puts "Parsing repository #{repo.full_name}..."
      puts # empty line for better visibility
      repo_result = @repo_parser.parse(repo)
      log_repo(repo, repo_result.lines_parsed)

      @lines_parsed += repo_result.lines_parsed
      write_result(repo_result)

      puts "Lines parsed so far: #{@lines_parsed}"
    end

    def parse_page(page_number)
      response = @client.search_repos("language:#{@language}",
                                      page: page_number)

      repos = response.items
      repos.each do |repo|
        handle_repo(repo)
        if @lines_parsed >= @lines_to_parse
          puts "Lines target reached. Stopping."
          break
        end
      end
    end

    private :clean_old_result, :print_divider, :log_repo, :parse_page
  end
end
