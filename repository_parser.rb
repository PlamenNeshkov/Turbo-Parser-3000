require_relative 'code_parser'

module TurboParser3000
  class RepositoryParser
    def initialize(language)
      assign_extension(language)
      @code_parser = CodeParser.new(language)
    end

    def assign_extension(language)
      case language
      when 'java'
        @file_extension = /.+\.java/i
      when 'cpp'
        @file_extension = /.+\.(c(c|p{2}|x{2})|h(h|p{2}|x{2}))/i
      when 'ruby'
        @file_extension = /.+\.rb/i
      end
    end

    def parse(repo)
      @result = Result.new
      FileUtils.cd('tmp')

      `git clone #{repo.clone_url}`
      Dir.glob("#{repo.name}/**/*").grep(@file_extension).each do |file|
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

    private :assign_extension, :parse_file
  end
end
