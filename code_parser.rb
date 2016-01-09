class CodeParser
  def initialize(language)
    @language = language
    @lines_parsed = 0

    case language
    when 'java'
      @word_pattern = /(?<=\W|^)[a-zA-Z_$][\w$]*/i
      @mark_pattern = /[\p{P}\p{S}\p{M}]/
    end

    @result = {}
  end

  def count_words(line)
    line.scan(@word_pattern).each do |word|
      if @result.key?(word)
        @result[word] += 1
      else
        @result[word] = 1
      end
    end
  end

  def count_marks(line)
    line.scan(@mark_pattern).each do
      if @result.key?('marks')
        @result['marks'] += 1
      else
        @result['marks'] = 1
      end
    end
  end

  def parse(code)
    code.each_line do |line|
      @lines_parsed += 1
      count_words(line)
      count_marks(line)
    end

    @result = @result.sort_by { |word, occur| [-occur, word] }
  end
end
