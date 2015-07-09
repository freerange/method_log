require 'spec_helper'

require 'method_log/method_diff'

module MethodLog
  describe MethodDiff do
    let(:first_commit) { double(:first_commit) }
    let(:second_commit) { double(:second_commit) }
    let(:diff) { MethodDiff.new(first_commit, second_commit) }

    it 'generates text diff of the method source for two commits' do
      allow(first_commit).to receive(:method_source)  { %{line 1\nline 2\n} }
      allow(second_commit).to receive(:method_source) { %{line 2\nline 3\n} }
      expect(diff.to_s).to eq(%{-line 1\n line 2\n+line 3\n})
    end
  end
end
