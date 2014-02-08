require 'ripper'

require 'method_log/method_definition'

module MethodLog
  class MethodFinder < Ripper
    def initialize(source_file:)
      super(source_file.source)
      @source_file = source_file
      @namespaces = []
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
      when 'class', 'module'
        @at_scope_start = true
      end
    end

    def on_const(name)
      if @at_scope_start
        @namespaces << name
        @at_scope_start = false
      end
    end

    def on_def(name, *args)
      identifier = "#{@namespaces.join('::')}##{name}"
      lines = (@line_number - 1)..(lineno - 1)
      definition = MethodDefinition.new(source_file: @source_file, lines: lines)
      @methods[identifier] = definition
    end

    def on_class(*args)
      @namespaces.pop
    end

    def on_module(*args)
      @namespaces.pop
    end
  end
end
