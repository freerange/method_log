require 'spec_helper'

require 'method_log/method_commit'
require 'method_log/commit'
require 'method_log/source_file'
require 'method_log/method_definition'

describe MethodLog::MethodCommit do
  let(:commit) { MethodLog::Commit.new(sha: nil) }
  let(:source_file) { MethodLog::SourceFile.new(path: '/path/to/source.rb', source: "line 0\nline 1\nline 2\n") }
  let(:method_definition) { MethodLog::MethodDefinition.new(source_file: source_file, lines: 0..1) }
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

  it 'returns method source with trailing newline' do
    expect(method_commit.method_source).to eq("line 0\nline 1\n")
  end

  it 'returns nil if no method definition' do
    method_commit = MethodLog::MethodCommit.new(commit: commit, method_definition: nil)
    expect(method_commit.method_source).to be_nil
  end
end
