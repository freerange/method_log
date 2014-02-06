module MethodLog
  class SourceFile
    attr_reader :path
    attr_reader :source

    def initialize(path:, source:)
      @path = path
      @source = source
    end

    def ==(other)
      (path == other.path) && (source == other.source)
    end

    def hash
      [path, source].hash
    end
  end
end