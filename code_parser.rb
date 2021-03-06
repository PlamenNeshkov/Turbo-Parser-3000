require_relative 'result'

module TurboParser3000
  class CodeParser
    def initialize(language)
      @language = language
      @total_lines_parsed = 0

      assign_pattern(language)

      @mark_pattern = /[\p{P}\p{S}\p{M}]/
    end

    def assign_pattern(language)
      case language
      when 'java'
        @word_pattern = /(?<=\W|^)[a-zA-Z_$][\w$]*/i
      when 'cpp'
        @word_pattern = /(?<=\W|^)[a-zA-Z_][\w]*/i
      when 'ruby'
        @word_pattern = /(?<=\W|^)[a-zA-Z$_@][\w$]*/i
      end
    end

    def parse(code)
      @words = {}
      @marks = 0

      lines_parsed = 0

      code.each_line do |line|
        lines_parsed += 1
        parse_line(line)
      end

      @total_lines_parsed += lines_parsed

      Result.new(lines_parsed, @words, @marks)
    end

    def parse_line(line)
      line = enforce_utf8(line)
      count_words(line)
      count_marks(line)
    end

    def enforce_utf8(text)
      text.encode('UTF-8', 'binary',
                  invalid: :replace,
                  undef: :replace,
                  replace: '')
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

    private :assign_pattern, :enforce_utf8, :parse_line,
            :count_words, :count_marks
  end
end
