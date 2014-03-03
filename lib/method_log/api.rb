require 'method_log/method_finder'
require 'method_log/method_commit'
require 'method_log/method_diff'

module MethodLog
  class API
    def initialize(repository)
      @repository = repository
    end

    def history(method_identifier, options = {})
      Enumerator.new do |yielder|
        last_method_commit = nil
        @repository.commits(options).each do |commit|
          last_source_file = last_method_commit && last_method_commit.source_file
          if last_source_file && commit.contains?(last_source_file)
            last_method_commit.update(commit)
          else
            method_definition = commit.find(method_identifier)
            yielder << last_method_commit if last_method_commit
            last_method_commit = MethodCommit.new(commit, method_definition)
            yielder << last_method_commit
          end
        end
      end
    end

    def diffs(method_identifier, options = {})
      Enumerator.new do |yielder|
        history(method_identifier, options).each_cons(2) do |(commit, parent)|
          diff = MethodDiff.new(parent, commit)
          unless diff.empty?
            yielder << [commit, diff]
          end
        end
      end
    end
  end
end
