module MethodLog
  class SourceFile
    attr_reader :path
    attr_reader :source

    def initialize(path: nil, source: nil)
      @path = path
      @source = source
    end

    def ==(other)
      (path == other.path) && (source == other.source)
    end

    def hash
      [path, source].hash
    end

    def snippet(range)
      lines = source.split($/)[range].join($/)
    end
  end
end