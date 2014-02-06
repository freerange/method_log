module MethodLog
  class MethodCommit
    def initialize(commit:, method_definition:)
      @commit = commit
      @method_definition = method_definition
    end

    def ==(other)
      (commit == other.commit) && (method_definition == other.method_definition)
    end

    def hash
      [commit, method_definition].hash
    end

    protected

    attr_reader :commit
    attr_reader :method_definition
  end
end
