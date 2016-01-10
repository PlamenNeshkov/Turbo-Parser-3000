require 'json'

module TurboParser3000
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
        if @words.key?(word)
          @words[word] += other.words[word]
        else
          @words[word] = other.words[word]
        end
      end

      @marks += other.marks
    end

    def to_json(language)
      result_hash = @words
      puts "Marks: #{@marks}"
      result_hash['marks'] = @marks
      json = JSON.pretty_generate(result_hash)
      File.write("result/#{language}.json", json)
    end

    def sort
      @words.sort_by { |word, occur| [-occur, word] }
    end

    def sort!
      @words = @words.sort_by { |word, occur| [-occur, word] }.to_h
    end
  end
end
