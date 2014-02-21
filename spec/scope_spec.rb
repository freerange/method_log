require 'spec_helper'

require 'method_log/scope'

describe MethodLog::Scope do
  let(:root) { MethodLog::Scope::Root.new }

  it 'ruby interactive style method identifier for top-level module' do
    a = root.define(:A)
    expect(a.method_identifier('foo')).to eq('A#foo')
  end

  it 'ruby interactive style method identifier for module nested inside top-level module' do
    a = root.define(:A)
    b = a.define(:B)
    expect(b.method_identifier('foo')).to eq('A::B#foo')
  end

  it 'ruby interactive style method identifier for module nested inside module nested inside top-level module' do
    a = root.define(:A)
    b = a.define(:B)
    c = b.define(:C)
    expect(c.method_identifier('foo')).to eq('A::B::C#foo')
  end

  it 'ruby interactive style method identifier for method on singleton class' do
    a = root.define(:A)
    singleton = a.singleton
    expect(singleton.method_identifier('foo')).to eq('A.foo')
  end

  it 'ruby interactive style method identifier for method on singleton class nested inside top-level module' do
    a = root.define(:A)
    b = a.define(:B)
    singleton = b.singleton
    expect(singleton.method_identifier('foo')).to eq('A::B.foo')
  end

  it 'looks up scope for top-level module' do
    a = root.define(:A)
    expect(a.lookup(:A)).to eq(a)
  end

  it 'looks up scopes for top-level module and nested module from nested module' do
    a = root.define(:A)
    b = a.define(:B)
    expect(b.lookup(:A)).to eq(a)
    expect(b.lookup(:B)).to eq(b)
  end

  it 'looks up scopes for modules from double-nested module' do
    a = root.define(:A)
    b = a.define(:B)
    c = b.define(:C)
    expect(c.lookup(:A)).to eq(a)
    expect(c.lookup(:B)).to eq(b)
    expect(c.lookup(:C)).to eq(c)
  end

  it 'looks up qualified module' do
    a = root.define(:A)
    b = a.define(:B)
    c = b.define(:C)
    expect(c.for([:A])).to eq(a)
    expect(c.for([:A, :B])).to eq(b)
    expect(c.for([:A, :B, :C])).to eq(c)
  end

  it 'defines missing modules' do
    root.for([:A, :B, :C])
    a = root.lookup(:A)
    b = a.lookup(:B)
    c = b.lookup(:C)
    expect(a).not_to be_nil
    expect(b).not_to be_nil
    expect(c).not_to be_nil
  end
end

