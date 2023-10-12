# frozen_string_literal: true

require "clipboard"

VERSION = File.read(File.expand_path("../VERSION", __dir__)).strip.freeze

module MDHost
  class CLI
    def initialize
      if ARGV.empty? || %w[--version -v].include?(ARGV.first)
        puts "mdhost version #{VERSION}"
        exit 0
      end

      @input = ARGV.first
    end

    def run
      # Display table
      system("eshost", "-h", "JavaScriptCore,SpiderMonkey,V8", "-te", @input)

      # Pretty escape the input (we'll be using it in the markdown so we want
      # it to look clean)
      escaped_input = if @input.include?("'") && @input.include?('"')
        "\"#{@input.gsub('"', '\"')}\""
      elsif @input.include?('"')
        "'#{@input}'"
      else
        "\"#{@input}\""
      end

      result = `eshost -e #{escaped_input}`.split(/\n+/)

      # We can't just #each_slice by 2, because sometimes an engine acts up and
      # produces no output, which would mess up the grouping. So, we need to
      # look specifically for the engines that we want and then take the next
      # line as the result.
      table = {}
      result.each_with_index do |line, i|
        if %w[JavaScriptCore SpiderMonkey V8].any? { |e| line.end_with? e }
          table[line.match(/\w+/).to_s.to_sym] = result[i + 1]
        end
      end

      # We don't *need* to pretty format the table so precisely, but why not?
      # The smallest this can be is 6 because of the length of the "Engine"
      # and "Result" headers.
      engine_length = [table.keys.max_by(&:length).length, 6].max
      result_length = [table.values.max_by(&:length).length, 6].max

      markdown_table = table.map do |e, r|
        "|#{e}#{' ' * (engine_length - e.length)}|#{r}#{' ' * (result_length - r.length)}|"
      end.join("\n")

      output = <<~EOS
        ```
        > eshost -te #{escaped_input}
        ```
        |Engine#{' ' * (engine_length - 6)}|Result#{' ' * (result_length - 6)}|
        |#{'-' * engine_length}|#{'-' * result_length}|
        #{markdown_table}
      EOS

      Clipboard.copy(output)
    end
  end
end
