require 'spec_helper'

require 'method_log/method_definition'
require 'method_log/source_file'

module MethodLog
  describe MethodDefinition do
    let(:source_file) do
      source(path: 'path/to/source.rb', source: %{
        class Foo
          def bar
            # implementation
          end
        end
      })
    end

    it 'is equal to another method definition with same source file and line numbers' do
      definition_one = MethodDefinition.new(source_file, 1..3)
      definition_two = MethodDefinition.new(source_file, 1..3)

      expect(definition_one).to eq(definition_two)
    end

    it 'has same hash as another method definition with same path and line numbers' do
      definition_one = MethodDefinition.new(source_file, 1..3)
      definition_two = MethodDefinition.new(source_file, 1..3)

      expect(definition_one.hash).to eq(definition_two.hash)
    end

    it 'provides access to the method source' do
      definition = MethodDefinition.new(source_file, 1..3)

      expect(definition.source).to eq(source_file.snippet(1..3))
    end
  end
end