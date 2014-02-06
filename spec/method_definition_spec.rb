require 'method_log/method_definition'

describe MethodLog::MethodDefinition do
  it 'is equal to another method definition with same path and line numbers' do
    definition_one = MethodLog::MethodDefinition.new(path: '/path/to/source.rb', lines: 5..7)
    definition_two = MethodLog::MethodDefinition.new(path: '/path/to/source.rb', lines: 5..7)

    expect(definition_one).to eq(definition_two)
  end

  it 'has same hash as another method definition with same path and line numbers' do
    definition_one = MethodLog::MethodDefinition.new(path: '/path/to/source.rb', lines: 5..7)
    definition_two = MethodLog::MethodDefinition.new(path: '/path/to/source.rb', lines: 5..7)

    expect(definition_one.hash).to eq(definition_two.hash)
  end
end
