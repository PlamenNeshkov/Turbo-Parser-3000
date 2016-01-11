module TurboParser3000
  class GraphGenerator
    HORIZONTAL_LIMIT = 10_000

    BAR_WIDTH = 10
    BAR_HEIGHT = 500 + BAR_WIDTH
    LABEL_OFFSET = 3

    def self.generate(language, result)
      words = result.words.reject { |k, _| ['marks'].include? k }

      File.open("result/#{language}.svg", 'w') do |f|
        f.write('<svg xmlns="http://www.w3.org/2000/svg">')
        write_bars(f, words)
        f.write('</svg>')
      end
    end

    def self.write_bars(file, words)
      ratio = (BAR_HEIGHT - BAR_WIDTH) / words.first[1].to_f
      offset = BAR_WIDTH

      words.each do |word, occurences|
        occurences *= ratio
        file.write(rectangle(offset, occurences))
        file.write(text(offset, word))
        offset += BAR_WIDTH

        break if offset >= HORIZONTAL_LIMIT
      end
    end    

    def self.rectangle(offset, occurences)
      x = offset
      y = BAR_HEIGHT - occurences
      w = BAR_WIDTH
      h = occurences

      %(<rect x="#{x}" y="#{y}"
      width="#{w}" height="#{h}"
      style="fill:blue;opacity:0.6;
      stroke:black;stroke-width:1;" />)
    end

    def self.text(offset, word)
      x = offset + LABEL_OFFSET
      y = BAR_HEIGHT + BAR_WIDTH / 2

      %(<text x="#{x}" y="#{y}" fill="red" font-size="10"
      transform="rotate(90 #{x}, #{y})">
      #{word}
      </text>)
    end

    private_class_method :write_bars, :rectangle, :text
  end
end
