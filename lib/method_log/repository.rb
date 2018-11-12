require 'rugged'

require 'method_log/commit'

module MethodLog
  class Repository
    def initialize(path)
      @repository = Rugged::Repository.new(path)
      @commits = []
    end

    def build_commit(sha = nil)
      Commit.new(sha, @repository)
    end

    def commit(*source_files)
      options = source_files.pop if source_files.last.is_a?(Hash)
      options ||= {}
      options = { user: { email: 'test@example.com', name: 'test', time: Time.now }, message: 'commit-message' }.merge(options)
      build_commit.tap do |commit|
        source_files.each { |sf| commit.add(sf) }
        commit.apply(options)
        @commits << commit
      end
    end

    def commits(options = {})
      Enumerator.new do |yielder|
        if @repository.ref('refs/heads/master')
          @repository.walk(@repository.last_commit, Rugged::SORT_TOPO).with_index do |commit, index|
            break if options[:max_count] && index >= options[:max_count] - 1
            yielder << build_commit(commit.oid)
          end
        end
      end
    end
  end
end
