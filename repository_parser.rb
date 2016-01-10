require_relative 'code_parser'

module TurboParser3000
  class RepositoryParser
    def initialize(language)
      case language
      when 'java'
        @file_extension = '.java'
      end
      @code_parser = CodeParser.new(language)
    end

    def parse(repo)
      @result = Result.new
      FileUtils.cd('tmp')

      `git clone #{repo.clone_url}`
      Dir.glob("#{repo.name}/**/*#{@file_extension}").each do |file|
        parse_file(file)
      end

      FileUtils.cd('..')
      @result
    end

    def parse_file(file)
      puts "Parsing #{file}"
      code = IO.read(file)
      file_result = @code_parser.parse(code)
      @result.merge(file_result)
    end

    private :parse_file
  end
end
