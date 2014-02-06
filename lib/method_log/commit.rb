require 'rugged'

module MethodLog
  class Commit
    attr_reader :sha
    attr_reader :source_files

    def initialize(sha: nil)
      @sha = sha
      @source_files = []
    end

    def add(source_file)
      @source_files << source_file
    end

    def apply(repository)
      index = Rugged::Index.new
      source_files.each do |source_file|
        oid = repository.write(source_file.source, :blob)
        index.add(path: source_file.path, oid: oid, mode: 0100644)
      end
      tree = index.write_tree(repository)
      parents = repository.empty? ? [] : [repository.head.target].compact
      user = { email: 'test@example.com', name: 'test', time: Time.now }
      @sha = Rugged::Commit.create(repository, tree: tree, parents: parents, update_ref: 'HEAD', author: user, committer: user, message: 'commit-message')
    end

    def ==(other)
      sha == other.sha
    end

    def hash
      sha.hash
    end
  end
end