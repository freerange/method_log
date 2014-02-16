module MethodLog
  class Scope
    attr_reader :parent

    def initialize(name: nil, parent: nil, singleton: false)
      @name = name
      @parent = parent
      @singleton = singleton
      @modules = {}
    end

    def define(name)
      @modules[name] = self.class.new(name: name, parent: self)
    end

    def lookup(name)
      @modules.fetch(name) do
        if @parent
          @parent.lookup(name)
        else
          raise NameError.new("uninitialized constant #{name}")
        end
      end
    end

    def singleton
      self.class.new(name: @name, parent: self, singleton: true)
    end

    def method_identifier(name)
      [names.join('::'), separator, name].join
    end

    protected

    def names
      names = @singleton ? [] : [@name]
      @parent && @parent.parent ? @parent.names + names : names
    end

    private

    def separator
      @singleton ? '.' : '#'
    end
  end
end
