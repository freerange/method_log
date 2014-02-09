require 'spec_helper'

require 'method_log/source_file'

describe MethodLog::SourceFile do
  it 'is equal to another source file with same path and source' do
    file_one = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source-one')
    file_two = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source-one')

    expect(file_one).to eq(file_two)
  end

  it 'has same hash as another source file with same path and source' do
    file_one = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source-one')
    file_two = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source-one')

    expect(file_one.hash).to eq(file_two.hash)
  end

  it 'describes source file' do
    file = MethodLog::SourceFile.new(path: 'path/to/source.rb', source: %{
class Foo
  def bar
    # implementation
  end
end
    }.strip)

    expect(file.snippet(1..3).strip).to eq(%{
  def bar
    # implementation
  end
    }.strip)
  end
end
