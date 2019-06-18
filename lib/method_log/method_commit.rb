module MethodLog
  class MethodCommit
    attr_reader :method_definition

    def initialize(commit, method_definition)
      @commit = commit
      @method_definition = method_definition
    end

    def update(commit)
      @commit = commit
    end

    def ==(other)
      (commit == other.commit) && (method_definition == other.method_definition)
    end

    def hash
      [commit, method_definition].hash
    end

    def sha
      commit.sha
    end

    def author
      commit.author
    end

    def message
      commit.message
    end

    def method_source
      method_definition && method_definition.source + $/
    end

    def source_file
      method_definition && method_definition.source_file
    end

    def to_s
      [
        "commit #{sha}",
        "Author: #{author[:name]} <#{author[:email]}>",
        "Date:   #{author[:time].strftime('%a %b %-e %T %Y %z')}",
        '',
        message
      ].join("\n")
    end

    protected

    attr_reader :commit
  end
end
