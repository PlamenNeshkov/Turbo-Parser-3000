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

    result = {}

    `git clone #{repo.clone_url}`
    Dir.glob("#{repo.name}/**/*#{@file_extension}").each do |file|
      code = IO.read(file)
      single_result = @code_parser.parse(code)
      result = result.merge(single_result) { |_, left, right| left + right }
    end

    FileUtils.cd('..')
    result
  end
end
