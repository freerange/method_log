require 'spec_helper'

require 'method_log/source_file'

module MethodLog
  describe SourceFile do
    let(:sha) { 'b54d38bbd989f4b54c38fd77767d89d1' }
    let(:repository) { double(:repository) }
    let(:blob) { double(:blob, text: 'source') }

    it 'is equal to another source file with same path and source' do
      file_one = source(path: 'path/to/source.rb', source: 'source-one')
      file_two = source(path: 'path/to/source.rb', source: 'source-one')

      expect(file_one).to eq(file_two)
    end

    it 'has same hash as another source file with same path and source' do
      file_one = source(path: 'path/to/source.rb', source: 'source-one')
      file_two = source(path: 'path/to/source.rb', source: 'source-one')

      expect(file_one.hash).to eq(file_two.hash)
    end

    it 'describes source file' do
      file = source(path: 'path/to/source.rb', source: unindent(%{
        class Foo
          def bar
            # implementation
          end
        end
      }))

      expect(file.snippet(1..3)).to eq(indent(unindent(%{
        def bar
          # implementation
        end
      })))
    end

    it 'looks up source in repository using SHA if no source set' do
      allow(repository).to receive(:lookup).with(sha).and_return(blob)
      file = source(path: 'path/to/source.rb', repository: repository, sha: sha)
      expect(file.source).to eq('source')
    end
  end
end
