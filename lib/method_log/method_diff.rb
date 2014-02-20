require 'diffy'

module MethodLog
  class MethodDiff
    def initialize(commit: nil, parent: nil)
      @commit, @parent = commit, parent
    end

    def to_s(mode = :text)
      Diffy::Diff.new(@commit.method_source, @parent.method_source).to_s(mode)
    end

    def empty?
      to_s.chomp.empty?
    end
  end
end
