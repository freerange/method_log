require 'method_log/method_definition'
require 'method_log/source_file'

describe MethodLog::MethodDefinition do
  let(:source_file) do
    MethodLog::SourceFile.new(path: 'path/to/source.rb', source: %{
class Foo
  def bar
    # implementation
  end
end
    }.strip)
  end

  it 'is equal to another method definition with same source file and line numbers' do
    definition_one = MethodLog::MethodDefinition.new(source_file: source_file, lines: 1..3)
    definition_two = MethodLog::MethodDefinition.new(source_file: source_file, lines: 1..3)

    expect(definition_one).to eq(definition_two)
  end

  it 'has same hash as another method definition with same path and line numbers' do
    definition_one = MethodLog::MethodDefinition.new(source_file: source_file, lines: 1..3)
    definition_two = MethodLog::MethodDefinition.new(source_file: source_file, lines: 1..3)

    expect(definition_one.hash).to eq(definition_two.hash)
  end

  it 'describes method definition' do
    definition = MethodLog::MethodDefinition.new(source_file: source_file, lines: 1..3)

    expect(definition.to_s).to eq(%{
  path/to/source.rb:1..3
  def bar
    # implementation
  end
    }.strip)
  end
end
