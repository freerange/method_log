require 'rugged'

module MethodLog
  class Repository
    attr_reader :commits

    def initialize(path:)
      @commits = []
      @repository = Rugged::Repository.init_at(path, :bare)
    end

    def add(commit)
      commit.apply(@repository)
      @commits << commit
    end
  end
end