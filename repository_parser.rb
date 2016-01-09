require_relative 'code_parser'

class RepositoryParser
  def initialize(language)
    case language
    when 'java'
      @file_extension = '.java'
    end
    @code_parser = CodeParser.new(language)
  end

  def parse(repo)
    FileUtils.cd('tmp')

    result = Result.new

    `git clone #{repo.clone_url}`
    Dir.glob("#{repo.name}/**/*#{@file_extension}").each do |file|
      code = IO.read(file)
      file_result = @code_parser.parse(code)
      result.merge(file_result)
    end

    p result

    FileUtils.cd('..')
    result
  end
end
