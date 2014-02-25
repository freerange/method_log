require 'rugged'

require 'method_log/source_file'

module MethodLog
  class Commit
    attr_reader :sha

    def initialize(repository: nil, sha: nil)
      @repository = repository
      @sha = sha
      @index = Rugged::Index.new
    end

    def add(source_file)
      oid = @repository.write(source_file.source, :blob)
      @index.add(path: source_file.path, oid: oid, mode: 0100644)
    end

    def apply(user: { email: 'test@example.com', name: 'test', time: Time.now }, message: 'commit-message')
      tree = @index.write_tree(@repository)
      parents = @repository.empty? ? [] : [@repository.head.target].compact
      @sha = Rugged::Commit.create(@repository, tree: tree, parents: parents, update_ref: 'HEAD', author: user, committer: user, message: message)
    end

    def source_files
      Enumerator.new do |yielder|
        commit.tree.walk_blobs do |root, blob_hash|
          name = blob_hash[:name]
          next unless File.extname(name) == '.rb'
          path = root.empty? ? name : File.join(root, name)
          source = @repository.lookup(blob_hash[:oid]).text
          yielder << SourceFile.new(path: path, source: source)
        end
      end
    end

    def author
      commit.author
    end

    def message
      commit.message
    end

    def ==(other)
      sha == other.sha
    end

    def hash
      sha.hash
    end

    def to_s
      sha
    end

    private

    def commit
      @commit ||= @repository.lookup(sha)
    end
  end
end