require 'diffy'

module MethodLog
  class MethodDiff
    def initialize(first_commit, second_commit)
      @first_commit, @second_commit = first_commit, second_commit
    end

    def to_s(mode = :text)
      Diffy::Diff.new(@first_commit.method_source, @second_commit.method_source).to_s(mode)
    end

    def empty?
      to_s.chomp.empty?
    end
  end
end
