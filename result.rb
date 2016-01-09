class Result
  attr_reader :lines_parsed, :words, :marks

  def initialize(lines_parsed = 0, words = {}, marks = 0)
    @lines_parsed = lines_parsed
    @words = words
    @marks = marks
  end

  def merge(other)
    @lines_parsed += other.lines_parsed
    other.words.each_key do |word|
      if (@words.has_key?(word))
        @words[word] += other.words[word]
      else
        @words[word] = other.words[word]
      end
    end
    @marks += other.marks
  end
end
