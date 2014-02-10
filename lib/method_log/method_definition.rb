module MethodLog
  class MethodDefinition
    def initialize(source_file: nil, lines: nil)
      @source_file = source_file
      @lines = lines
    end

    def ==(other)
      (source_file == other.source_file) && (lines == other.lines)
    end

    def hash
      [source_file, lines].hash
    end

    def to_s
      [
        "#{source_file.path}:#{lines}",
        source_file.snippet(lines)
      ].join($/)
    end

    protected

    attr_reader :source_file
    attr_reader :lines
  end
end