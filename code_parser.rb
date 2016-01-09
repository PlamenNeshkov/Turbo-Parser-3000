require_relative 'result'

class CodeParser
  def initialize(language)
    @language = language
    @total_lines_parsed = 0

    case language
    when 'java'
      @word_pattern = /(?<=\W|^)[a-zA-Z_$][\w$]*/i
      @mark_pattern = /[\p{P}\p{S}\p{M}]/
    end
  end

  def count_words(line)
    line.scan(@word_pattern).each do |word|
      if @words.key?(word)
        @words[word] += 1
      else
        @words[word] = 1
      end
    end
  end

  def count_marks(line)
    line.scan(@mark_pattern).each do
      @marks += 1
    end
  end

  def parse(code)
    @words = {}
    @marks = 0

    lines_parsed = 0

    code.each_line do |line|
      lines_parsed += 1
      count_words(line)
      count_marks(line)
    end

    @total_lines_parsed += lines_parsed

    @words = @words.sort_by { |word, occur| [-occur, word] }.to_h
    result = Result.new(lines_parsed, @words, @marks)
  end
end
