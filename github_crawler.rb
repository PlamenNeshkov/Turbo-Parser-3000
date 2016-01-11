require_relative 'repository_parser'
require_relative 'graph_generator'

require 'fileutils'
require 'colorize'
require 'octokit'
require 'csv'

module TurboParser3000
  class GitHubCrawler
    def initialize(client, language, lines_to_parse)
      clean_old_result

      @language = language.downcase.sub('c++', 'cpp')
      @lines_to_parse = lines_to_parse.to_i
      @lines_parsed = 0

      @client = client

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

    def parse_page(page_number)
      response = @client.search_repos("language:#{@language}",
                                      page: page_number)

      repos = response.items
      repos.each do |repo|
        handle_repo(repo)
        if @lines_parsed >= @lines_to_parse
          stop
          break
        end
      end
    end

    def handle_repo(repo)
      print_divider

      puts "Parsing repository #{repo.full_name}..."
      empty_line
      repo_result = @repo_parser.parse(repo)
      log_repo(repo, repo_result.lines_parsed)

      @lines_parsed += repo_result.lines_parsed
      write_result(repo_result)

      empty_line
      puts "Lines parsed so far: #{@lines_parsed}"
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

    def sort_repositories
      sorted_csv = CSV.read('result/repositories.csv')
      sorted_csv.sort! { |a, b| b[2].to_i <=> a[2].to_i }

      CSV.open('result/repositories.csv', 'w') do |csv|
        sorted_csv.each do |row|
          csv << row
        end
      end
    end

    def stop
      puts 'Lines target reached. Stopping.'

      print 'Generating bar graph... '
      GraphGenerator.generate(@language, @result)
      puts 'generated!'.green

      sort_repositories
    end

    def print_divider
      puts '-' * 80
    end

    def clean_old_result
      FileUtils.rm_rf(Dir.glob('tmp/**/*'))
      FileUtils.mkdir('result') unless File.exists?('result')
      FileUtils.mkdir('tmp') unless File.exists?('tmp')
    end

    def empty_line
      puts
    end

    private :clean_old_result, :print_divider, :log_repo, :empty_line,
            :write_result, :handle_repo, :parse_page, :stop
  end
end
