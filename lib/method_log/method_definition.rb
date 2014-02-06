module MethodLog
  class MethodDefinition
    def initialize(path:, lines:)
      @path = path
      @lines = lines
    end

    def ==(other)
      (path == other.path) && (lines == other.lines)
    end

    def hash
      [path, lines].hash
    end

    protected

    attr_reader :path
    attr_reader :lines
  end
end