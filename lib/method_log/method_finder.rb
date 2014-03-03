unless defined?(Parser::CurrentRuby)
  require 'parser/current'
end

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
      with_scope(@scope.for(constants).define(new_constant)) { super }
    end

    alias_method :on_class, :on_module

    def on_sclass(node)
      target_node = node.children.first
      with_scope(singleton_scope_for(target_node)) { super }
    end

    def on_def(node)
      name, args_node, body_node = *node
      record_method_definition(@scope, name, node)
      super
    end

    def on_defs(node)
      definee_node, name, args_node, body_node = *node
      scope = singleton_scope_for(definee_node)
      record_method_definition(scope, name, node)
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
        @scope.define(node.inspect).singleton
      end
    end

    def process_const(node, namespaces = [])
      scope_node, name = *node
      namespace = (node.type == :cbase) ? :root : name
      namespaces.unshift(namespace)
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

    def record_method_definition(scope, name, node)
      definition = MethodDefinition.new(@source_file, lines_for(node))
      identifier = scope.method_identifier(name)
      @methods[identifier] = definition
    end

    def with_scope(scope, &block)
      @scope = scope
      yield
    ensure
      @scope = scope.parent
    end
  end
end
