require 'method_log/method_definition'
require 'method_log/source_file'

describe MethodLog::MethodDefinition do
  let(:source_file) { MethodLog::SourceFile.new(path: 'path/to/source.rb', source: 'source') }

  it 'is equal to another method definition with same source file and line numbers' do
    definition_one = MethodLog::MethodDefinition.new(source_file: source_file, lines: 5..7)
    definition_two = MethodLog::MethodDefinition.new(source_file: source_file, lines: 5..7)

    expect(definition_one).to eq(definition_two)
  end

  it 'has same hash as another method definition with same path and line numbers' do
    definition_one = MethodLog::MethodDefinition.new(source_file: source_file, lines: 5..7)
    definition_two = MethodLog::MethodDefinition.new(source_file: source_file, lines: 5..7)

    expect(definition_one.hash).to eq(definition_two.hash)
  end
end
