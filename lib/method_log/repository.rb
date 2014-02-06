require 'rugged'

require 'method_log/commit'

module MethodLog
  class Repository
    attr_reader :commits

    def initialize(path:)
      @commits = []
      @repository = Rugged::Repository.init_at(path, :bare)
    end

    def build_commit
      Commit.new(repository: @repository)
    end

    def add(commit)
      commit.apply
      @commits << commit
    end
  end
end