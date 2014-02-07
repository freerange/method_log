require 'spec_helper'

require 'method_log/api'
require 'method_log/source_file'
require 'method_log/repository'
require 'method_log/commit'
require 'method_log/method_definition'
require 'method_log/method_commit'

describe MethodLog::API do
  let(:repository_path) { File.expand_path('../repository.git', __FILE__) }

  before do
    FileUtils.mkdir_p(repository_path)
    Rugged::Repository.init_at(repository_path, :bare)
  end

  after do
    FileUtils.rm_rf(repository_path)
  end

  it 'finds class instance method in repository with single commit with single source file' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: %{
class Foo
  def bar
    # implementation
  end
end
    }.strip)

    repository = MethodLog::Repository.new(path: repository_path)
    commit = repository.build_commit
    commit.add(foo)
    repository.add(commit)

    repository = MethodLog::Repository.new(path: repository_path)
    api = MethodLog::API.new(repository: repository)
    method_commits = api.history('Foo#bar')

    method_definition = MethodLog::MethodDefinition.new(path: foo.path, lines: 1..3)
    method_commit = MethodLog::MethodCommit.new(commit: commit, method_definition: method_definition)
    expect(method_commits).to eq([method_commit])
  end
end
