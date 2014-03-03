$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

module MethodLog
  module SourceHelper
    def source(options = {})
      options[:source] = options[:source] ? unindent(options[:source]) : options[:source]
      SourceFile.new(options)
    end

    def unindent(code)
      lines = code.split($/)
      indent = lines.reject { |l| l.strip.length == 0 }.map { |l| l[/^\s*/].length }.min
      fixed_lines = lines.map { |l| l.sub(Regexp.new(' ' * indent), '') }
      fixed_lines.drop_while { |l| l.strip.length == 0 }.take_while { |l| l.strip.length > 0 }.join($/)
    end

    def indent(code, spaces = 2)
      lines = code.split($/)
      lines.map { |l| "#{' ' * spaces}#{l}"}.join($/)
    end
  end
end

RSpec.configure do |config|
  config.include MethodLog::SourceHelper
end
