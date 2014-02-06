require 'spec_helper'

require 'method_log/source_file'
require 'method_log/method_finder'

describe MethodLog::MethodFinder do
  it 'finds definition of instance method on class' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: %{
class Foo
  def bar
    # implementation
  end
end
    }.strip)

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo#bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(path: foo.path, lines: 1..3))
  end
end
