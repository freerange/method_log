module MethodLog
  class Scope
    class Null < Scope
      def initialize
        super(name: 'null')
      end

      def lookup(name)
        raise NameError.new("uninitialized constant #{name}")
      end
    end

    class Root < Scope
      def initialize
        super(name: 'root', parent: Scope::Null.new)
      end

      def names
        []
      end
    end

    attr_reader :parent

    def initialize(name: nil, parent: nil, singleton: false)
      @name = name
      @parent = parent
      @singleton = singleton
      @modules = {}
    end

    def for(modules)
      scope = self
      modules.each { |m| scope = scope.lookup(m) }
      scope
    end

    def define(name)
      @modules[name] = Scope.new(name: name, parent: self)
    end

    def lookup(name)
      @modules.fetch(name) { @parent.lookup(name) }
    end

    def singleton
      Scope.new(name: @name, parent: self, singleton: true)
    end

    def method_identifier(name)
      [names.join('::'), separator, name].join
    end

    protected

    def names
      names = @singleton ? [] : [@name]
      names = @parent.names + names
    end

    private

    def separator
      @singleton ? '.' : '#'
    end
  end
end
