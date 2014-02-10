require 'rugged'

require 'method_log/commit'

module MethodLog
  class Repository
    attr_reader :commits

    def initialize(path: nil)
      @repository = Rugged::Repository.new(path)
      @commits = []
      if @repository.ref('refs/heads/master')
        @repository.walk(@repository.last_commit) do |commit|
          @commits << build_commit(sha: commit.oid)
        end
      end
    end

    def build_commit(sha: nil)
      Commit.new(repository: @repository, sha: sha)
    end

    def add(commit)
      commit.apply
      @commits << commit
    end
  end
end