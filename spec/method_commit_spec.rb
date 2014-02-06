require 'method_log/method_commit'
require 'method_log/commit'
require 'method_log/method_definition'

describe MethodLog::MethodCommit do
  let(:commit) { MethodLog::Commit.new }
  let(:method_definition) { MethodLog::MethodDefinition.new(path: '/path/to/source.rb', lines: 5..7) }
  let(:method_commit) {
    MethodLog::MethodCommit.new(commit: commit, method_definition: method_definition)
  }
  let(:method_commit_with_same_commit_and_method_definition) {
    MethodLog::MethodCommit.new(commit: commit, method_definition: method_definition)
  }

  it 'is equal to another method commit with same commit and method definition' do
    expect(method_commit).to eq(method_commit_with_same_commit_and_method_definition)
  end

  it 'has same hash as another method commit with same commit and method definition' do
    expect(method_commit.hash).to eq(method_commit_with_same_commit_and_method_definition.hash)
  end
end
