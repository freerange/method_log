module MethodLog
  class SourceFile
    attr_reader :path
    attr_reader :source

    def initialize(path:, source:)
      @path = path
      @source = source
    end
  end
end