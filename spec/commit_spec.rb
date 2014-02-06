require 'method_log/commit'

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
end
