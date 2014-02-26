module MethodLog
  class MethodDefinition
    attr_reader :source_file

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

    def source
      source_file.snippet(lines)
    end

    protected

    attr_reader :lines
  end
end