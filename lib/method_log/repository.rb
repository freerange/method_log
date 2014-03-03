require 'rugged'

require 'method_log/commit'

module MethodLog
  class Repository
    def initialize(path)
      @repository = Rugged::Repository.new(path)
      @commits = []
    end

    def build_commit(sha: nil)
      Commit.new(sha, @repository)
    end

    def commit(*source_files, user: { email: 'test@example.com', name: 'test', time: Time.now }, message: 'commit-message')
      build_commit.tap do |commit|
        source_files.each { |sf| commit.add(sf) }
        commit.apply(user: user, message: message)
        @commits << commit
      end
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