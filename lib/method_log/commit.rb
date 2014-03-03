require 'rugged'

require 'method_log/source_file'

module MethodLog
  class Commit
    attr_reader :sha

    def initialize(sha, repository = nil)
      @repository = repository
      @sha = sha
      @index = Rugged::Index.new
    end

    def add(source_file)
      oid = @repository.write(source_file.source, :blob)
      @index.add(path: source_file.path, oid: oid, mode: 0100644)
    end

    def apply(user: nil, message: nil)
      tree = @index.write_tree(@repository)
      parents = @repository.empty? ? [] : [@repository.head.target].compact
      @sha = Rugged::Commit.create(@repository, tree: tree, parents: parents, update_ref: 'HEAD', author: user, committer: user, message: message)
    end

    def source_files
      @source_files ||= Enumerator.new do |yielder|
        commit.tree.walk_blobs do |root, blob_hash|
          name = blob_hash[:name]
          next unless File.extname(name) == '.rb'
          path = root.empty? ? name : File.join(root, name)
          yielder << SourceFile.new(path: path, repository: @repository, sha: blob_hash[:oid])
        end
      end
    end

    def contains?(source_file)
      source_files_by_path[source_file.path] == source_file
    end

    def find(method_identifier)
      method_definition = nil
      method_name = method_identifier.split(Regexp.union('#', '.')).last
      source_files.each do |source_file|
        next unless source_file.source[Regexp.new(method_name)]
        method_finder = MethodFinder.new(source_file: source_file)
        break if method_definition = method_finder.find(method_identifier)
      end
      method_definition
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

    def source_files_by_path
      source_files.inject({}) do |hash, source_file|
        hash[source_file.path] = source_file
        hash
      end
    end
  end
end