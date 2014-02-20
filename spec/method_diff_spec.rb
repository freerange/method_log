require 'method_log/method_diff'

describe MethodLog::MethodDiff do
  let(:commit) { double(:commit) }
  let(:parent) { double(:parent) }
  let(:diff) { MethodLog::MethodDiff.new(commit: commit, parent: parent) }

  it 'generates text diff of the method source for two commits' do
    commit.stub(:method_source).and_return(%{line 1\nline 2\n})
    parent.stub(:method_source).and_return(%{line 2\nline 3\n})
    expect(diff.to_s).to eq(%{-line 1\n line 2\n+line 3\n})
  end
end
