require 'ripper'

require 'method_log/method_definition'

module MethodLog
  class MethodFinder < Ripper
    def initialize(source_file:)
      super(source_file.source)
      @source_file = source_file
      @methods = {}
      @at_scope_start = false
      parse
    end

    def find(method_identifier)
      @methods[method_identifier]
    end

    def on_kw(name)
      case name
      when 'def'
        @line_number = lineno
      when 'class'
        @at_scope_start = true
      end
    end

    def on_const(name)
      if @at_scope_start
        @klass = name
        @at_scope_start = false
      end
    end

    def on_def(name, *args)
      identifier = "#{@klass}##{name}"
      lines = (@line_number - 1)..(lineno - 1)
      definition = MethodDefinition.new(path: @source_file.path, lines: lines)
      @methods[identifier] = definition
    end
  end
end
