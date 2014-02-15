require 'parser/current'

require 'method_log/method_definition'

module MethodLog
  class MethodFinder < Parser::AST::Processor
    def initialize(source_file: nil)
      @source_file = source_file
      @namespaces = []
      @methods = {}
      ast = Parser::CurrentRuby.parse(source_file.source)
      process(ast)
    end

    def find(method_identifier)
      @methods[method_identifier]
    end

    def on_module(node)
      scope_node, name = *node.children.first
      @namespaces.push(name)
      super
      @namespaces.pop
    end

    def on_class(node)
      const_node = node.children.first
      scope_node, name = *const_node
      @namespaces.push(name)
      super
      @namespaces.pop
    end

    def on_def(node)
      name, args_node, body_node = *node
      expression = node.location.expression
      first_line = expression.line - 1
      last_line = expression.source_buffer.decompose_position(expression.end_pos).first - 1
      lines = first_line..last_line
      definition = MethodDefinition.new(source_file: @source_file, lines: lines)
      identifier = "#{@namespaces.join('::')}##{name}"
      @methods[identifier] = definition
      super
    end
  end
end
