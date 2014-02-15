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

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 1..3))
  end

  it 'finds definition of instance method on module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: %{
module Foo
  def bar
    # implementation
  end
end
    }.strip)

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo#bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 1..3))
  end

  it 'finds definition of instance method on class within module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: %{
module Foo
  class Bar
    def baz
      # implementation
    end
  end
end
    }.strip)

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::Bar#baz')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 2..4))
  end

  it 'finds definition of instance method on namespaced class within previously defined module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: %{
module Foo
end

class Foo::Bar
  def baz
    # implementation
  end
end
    }.strip)

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::Bar#baz')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 4..6))
  end
end
