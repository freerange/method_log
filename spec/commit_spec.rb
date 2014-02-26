require 'method_log/repository'
require 'method_log/commit'
require 'method_log/source_file'

describe MethodLog::Commit do
  let(:sha) { 'b54d38bbd989f4b54c38fd77767d89d1' }
  let(:commit) { MethodLog::Commit.new(sha: sha) }
  let(:commit_with_same_sha) { MethodLog::Commit.new(sha: sha) }

  it 'is equal to another commit with same SHA' do
    expect(commit).to eq(commit_with_same_sha)
  end

  it 'has same hash as another commit with same SHA' do
    expect(commit.hash).to eq(commit_with_same_sha.hash)
  end

  context 'using a real git repository' do
    let(:repository_path) { File.expand_path('../repository.git', __FILE__) }

    before do
      FileUtils.mkdir_p(repository_path)
      Rugged::Repository.init_at(repository_path, :bare)
    end

    after do
      FileUtils.rm_rf(repository_path)
    end

    it 'stores source files added to a commit in the repository against a real commit' do
      source_one = MethodLog::SourceFile.new(path: 'path/to/source_one.rb', source: 'source-one')
      source_two = MethodLog::SourceFile.new(path: 'path/to/source_two.rb', source: 'source-two')

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.build_commit
      commit.add(source_one)
      commit.add(source_two)
      commit.apply

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.commits.first
      expect(commit.source_files.to_a).to eq([source_one, source_two])
    end

    it 'only includes source files with ruby file extension' do
      source_file = MethodLog::SourceFile.new(path: 'path/to/source_one.py', source: 'source-file')

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.build_commit
      commit.add(source_file)
      commit.apply

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.commits.first
      expect(commit.source_files.to_a).to be_empty
    end

    it 'indicates whether it contains a given source file' do
      source_file = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source-file')

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.build_commit
      commit.add(source_file)
      commit.apply
      source_file = commit.source_files.first

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.commits.first
      expect(commit.contains?(source_file)).to be_true
    end

    it 'makes author available' do
      user = { email: 'test@example.com', name: 'test', time: Time.now.round }
      source_file = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source')

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.build_commit
      commit.add(source_file)
      commit.apply(user: user)

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.commits.first
      expect(commit.author).to eq(user)
    end

    it 'makes message available' do
      source_file = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source')

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.build_commit
      commit.add(source_file)
      commit.apply(message: 'commit-message')

      repository = MethodLog::Repository.new(path: repository_path)
      commit = repository.commits.first
      expect(commit.message).to eq('commit-message')
    end
  end
end
