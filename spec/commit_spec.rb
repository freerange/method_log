require 'spec_helper'

require 'method_log/repository'
require 'method_log/commit'
require 'method_log/source_file'

module MethodLog
  describe Commit do
    let(:sha) { 'b54d38bbd989f4b54c38fd77767d89d1' }
    let(:commit) { Commit.new(sha: sha) }
    let(:commit_with_same_sha) { Commit.new(sha: sha) }

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
        source_one = source(path: 'path/to/source_one.rb', source: 'source-one')
        source_two = source(path: 'path/to/source_two.rb', source: 'source-two')

        repository = Repository.new(path: repository_path)
        commit = repository.commit(source_one, source_two)

        repository = Repository.new(path: repository_path)
        commit = repository.commits.first
        expect(commit.source_files.to_a).to eq([source_one, source_two])
      end

      it 'only includes source files with ruby file extension' do
        source_file = source(path: 'path/to/source_one.py', source: 'source-file')

        repository = Repository.new(path: repository_path)
        commit = repository.commit(source_file)

        repository = Repository.new(path: repository_path)
        commit = repository.commits.first
        expect(commit.source_files.to_a).to be_empty
      end

      it 'indicates whether it contains a given source file' do
        source_file = source(path: 'path/to/source.rb', source: 'source-file')
        another_source_file = source(path: 'path/to/another_source.rb', source: 'another-source-file')

        repository = Repository.new(path: repository_path)
        commit = repository.commit(source_file)
        source_file = commit.source_files.first
        another_commit = repository.commit(another_source_file)
        another_source_file = another_commit.source_files.first

        repository = Repository.new(path: repository_path)
        commit = repository.commits.to_a.last

        expect(commit.contains?(source_file)).to be_true
        expect(commit.contains?(another_source_file)).to be_false
      end

      it 'makes author available' do
        user = { email: 'test@example.com', name: 'test', time: Time.now.round }
        source_file = source(path: 'path/to/source.rb', source: 'source')

        repository = Repository.new(path: repository_path)
        commit = repository.commit(source_file, user: user)

        repository = Repository.new(path: repository_path)
        commit = repository.commits.first
        expect(commit.author).to eq(user)
      end

      it 'makes message available' do
        source_file = source(path: 'path/to/source.rb', source: 'source')

        repository = Repository.new(path: repository_path)
        commit = repository.commit(source_file, message: 'commit-message')

        repository = Repository.new(path: repository_path)
        commit = repository.commits.first
        expect(commit.message).to eq('commit-message')
      end
    end
  end
end