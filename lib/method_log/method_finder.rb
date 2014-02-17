require 'parser/current'

require 'method_log/method_definition'
require 'method_log/scope'

module MethodLog
  class MethodFinder < Parser::AST::Processor
    def initialize(source_file: nil)
      @source_file = source_file
      @scope = Scope::Root.new
      @methods = {}
      ast = Parser::CurrentRuby.parse(source_file.source)
      process(ast)
    end

    def find(method_identifier)
      @methods[method_identifier]
    end

    def on_module(node)
      const_node = node.children.first
      constants = process_const(const_node)
      new_constant = constants.pop
      @scope = @scope.for(constants).define(new_constant)
      super
      @scope = @scope.parent
    end

    def on_class(node)
      const_node = node.children.first
      constants = process_const(const_node)
      new_constant = constants.pop
      @scope = @scope.for(constants).define(new_constant)
      super
      @scope = @scope.parent
    end

    def on_sclass(node)
      target_node = node.children.first
      @scope = singleton_scope_for(target_node)
      super
      @scope = @scope.parent
    end

    def on_def(node)
      name, args_node, body_node = *node
      definition = MethodDefinition.new(source_file: @source_file, lines: lines_for(node))
      identifier = @scope.method_identifier(name)
      @methods[identifier] = definition
      super
    end

    def on_defs(node)
      definee_node, name, args_node, body_node = *node
      scope = singleton_scope_for(definee_node)
      definition = MethodDefinition.new(source_file: @source_file, lines: lines_for(node))
      identifier = scope.method_identifier(name)
      @methods[identifier] = definition
      super
    end

    private

    def singleton_scope_for(node)
      case node.type
      when :self
        @scope.singleton
      when :const
        constants = process_const(node)
        @scope.for(constants).singleton
      else
        raise
      end
    end

    def process_const(node, namespaces = [])
      scope_node, name = *node
      namespaces.unshift(name)
      if scope_node
        process_const(scope_node, namespaces)
      end
      namespaces
    end

    def lines_for(node)
      expression = node.location.expression
      first_line = expression.line - 1
      last_line = expression.source_buffer.decompose_position(expression.end_pos).first - 1
      first_line..last_line
    end
  end
end
