require 'rugged'

require 'method_log/commit'

module MethodLog
  class Repository
    def initialize(path: nil)
      @repository = Rugged::Repository.new(path)
      @commits = []
    end

    def build_commit(sha: nil)
      Commit.new(repository: @repository, sha: sha)
    end

    def add(commit)
      commit.apply
      @commits << commit
    end

    def commits(max_count: nil)
      Enumerator.new do |yielder|
        if @repository.ref('refs/heads/master')
          @repository.walk(@repository.last_commit).with_index do |commit, index|
            break if max_count && index >= max_count - 1
            yielder << build_commit(sha: commit.oid)
          end
        end
      end
    end
  end
end