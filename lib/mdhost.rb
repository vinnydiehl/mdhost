# frozen_string_literal: true

require "clipboard"
require "optimist"

FORMAT_SPECIFIER = '#{}'

module MDHost
  class CLI
    def initialize
      @options = Optimist.options do
        version "mdhost #{File.read(File.expand_path('../VERSION', __dir__)).strip}"

        banner <<~BANNER
          #{version}

          Usage:
            mdhost INPUT
            mdhost --format FORMAT_STRING INPUTS...

          Given a format string, inputs will be formatted to the location of
          the sequence #{FORMAT_SPECIFIER}

          Options:
        BANNER

        opt :format, "Format string to compose multiple inputs into", type: :string

        educate_on_error
      end

      if ARGV.empty?
        Optimist::educate
      end
    end

    def run
      if (@format_string = @options.format)
        Optimist::educate unless @format_string.include?(FORMAT_SPECIFIER)
        run_format
      else
        @input = ARGV.first
        run_single_input
      end
    end

    # Pretty escape the input (we might be using it in the markdown so
    # we want it to look clean)
    def escape_input(input)
      if input.include?("'") && input.include?('"')
        "\"#{input.gsub('"', '\"')}\""
      elsif input.include?('"')
        "'#{input}'"
      else
        "\"#{input}\""
      end
    end

    def display_table(input)
      system("eshost", "-h", "JavaScriptCore,SpiderMonkey,V8", "-te", input)
    end

    def results_for(escaped_input)
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

      table
    end

    def run_single_input
      display_table @input

      escaped_input = escape_input @input

      result = `eshost -e #{escaped_input}`.split(/\n+/)

      table = results_for escaped_input

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

    def run_format
      inputs = ARGV.map { |s| @format_string.sub(FORMAT_SPECIFIER, s) }
      inputs.each do |input|
        puts input
        display_table input
      end

      output = +<<~TABLE
        |Input|JavaScriptCore|SpiderMonkey|V8
        |-----|--------------|------------|--
      TABLE

      inputs.each do |input|
        escaped_input = escape_input input
        results = results_for escaped_input

        output << <<~ROW
          |`#{input}`|#{results[:JavaScriptCore]}|#{results[:SpiderMonkey]}|#{results[:V8]}
        ROW
      end

      Clipboard.copy(output)
    end
  end
end
