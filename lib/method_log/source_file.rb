module MethodLog
  class SourceFile
    attr_reader :path
    attr_reader :sha

    def initialize(options = {})
      @path = options[:path]
      @source = options[:source]
      @repository = options[:repository]
      @sha = options[:sha]
    end

    def source
      @source ||= @repository.lookup(@sha).text
    end

    def ==(other)
      (path == other.path) && (source == other.source)
    end

    def hash
      @sha || [path, source].hash
    end

    def snippet(range)
      lines = source.split($/)[range].join($/)
    end
  end
end