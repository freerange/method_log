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
      const_node = node.children.first
      @namespaces.push(process_const(const_node))
      super
      @namespaces.pop
    end

    def on_class(node)
      const_node = node.children.first
      @namespaces.push(process_const(const_node))
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
      identifier = "#{@namespaces.flatten.join('::')}##{name}"
      @methods[identifier] = definition
      super
    end

    def on_defs(node)
      definee_node, name, args_node, body_node = *node
      expression = node.location.expression
      first_line = expression.line - 1
      last_line = expression.source_buffer.decompose_position(expression.end_pos).first - 1
      lines = first_line..last_line
      definition = MethodDefinition.new(source_file: @source_file, lines: lines)
      identifier = "#{@namespaces.flatten.join('::')}.#{name}"
      @methods[identifier] = definition
      super
    end

    private

    def process_const(node, namespaces = [])
      scope_node, name = *node
      namespaces.unshift(name)
      if scope_node
        process_const(scope_node, namespaces)
      end
      namespaces
    end
  end
end
