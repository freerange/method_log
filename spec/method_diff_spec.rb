require 'method_log/method_diff'

describe MethodLog::MethodDiff do
  let(:first_commit) { double(:first_commit) }
  let(:second_commit) { double(:second_commit) }
  let(:diff) { MethodLog::MethodDiff.new(first_commit: first_commit, second_commit: second_commit) }

  it 'generates text diff of the method source for two commits' do
    first_commit.stub(:method_source).and_return(%{line 1\nline 2\n})
    second_commit.stub(:method_source).and_return(%{line 2\nline 3\n})
    expect(diff.to_s).to eq(%{-line 1\n line 2\n+line 3\n})
  end
end
