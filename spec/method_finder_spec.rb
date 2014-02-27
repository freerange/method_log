require 'spec_helper'

require 'method_log/source_file'
require 'method_log/method_finder'

describe MethodLog::MethodFinder do
  it 'finds definition of instance method on class' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      class Foo
        def bar
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo#bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 1..3))
  end

  it 'finds definition of instance method on module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
        def bar
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo#bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 1..3))
  end

  it 'finds definition of instance method on class within module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
        class Bar
          def baz
            # implementation
          end
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::Bar#baz')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 2..4))
  end

  it 'finds definition of instance method on namespaced class within previously defined module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
      end
      class Foo::Bar
        def baz
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::Bar#baz')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 3..5))
  end

  it 'finds definition of instance method on namespaced module within previously defined module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
      end
      module Foo::Bar
        def baz
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::Bar#baz')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 3..5))
  end

  it 'finds definition of class method on class' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
        def self.bar
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo.bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 1..3))
  end

  it 'finds definition of class method on class with explicit reference to class' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
        def Foo.bar
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo.bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 1..3))
  end

  it 'finds definition of class method on class with explicit reference to namespaced class' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
        class Bar
          def (Foo::Bar).baz
            # implementation
          end
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::Bar.baz')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 2..4))
  end

  it 'finds definition of class method on class with explicit reference to namespaced class outside current scope' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      class Foo
      end
      class Bar
        def Foo.baz
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo.baz')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 3..5))
  end

  it 'finds definition of class method on class when singleton class is re-opened' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      class Foo
        class << self
          def bar
            # implementation
          end
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo.bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 2..4))
  end

  it 'finds definition of class method on class when singleton class is re-opened with explicit reference to class' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      class Foo
        class << Foo
          def bar
            # implementation
          end
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo.bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 2..4))
  end

  it 'finds definition of class method on class when singleton class is re-opened with explicit reference to class outside current scope' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      class Foo
      end
      class Bar
        class << Foo
          def bar
            # implementation
          end
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo.bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 4..6))
  end

  it 'finds definition of class method on unknown object when singleton class is re-opened' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      class Foo
        def initialize
          @foo = new
          class << @foo
            def bar
              # implementation
            end
          end
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::(ivar :@foo).bar')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 4..6))
  end

  it 'finds definition of class method on ambiguous module referenced via top-level module' do
    foo = MethodLog::SourceFile.new(path: 'foo.rb', source: unindent(%{
      module Foo
        class Bar; end
      end
      module Baz
        module Foo
          class Bar; end
        end
        def (::Foo::Bar).foo
          # implementation
        end
      end
    }))

    method_finder = MethodLog::MethodFinder.new(source_file: foo)
    method_definition = method_finder.find('Foo::Bar.foo')

    expect(method_definition).to eq(MethodLog::MethodDefinition.new(source_file: foo, lines: 7..9))
  end
end
