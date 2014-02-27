require 'method_log/method_finder'
require 'method_log/method_commit'
require 'method_log/method_diff'

module MethodLog
  class API
    def initialize(repository: nil)
      @repository = repository
    end

    def history(method_identifier, max_count: nil)
      method_name = method_identifier.split(Regexp.union('#', '.')).last
      Enumerator.new do |yielder|
        last_method_commit = nil
        @repository.commits(max_count: max_count).each do |commit|
          last_source_file = last_method_commit && last_method_commit.source_file
          if last_source_file && commit.contains?(last_source_file)
            last_method_commit = MethodCommit.new(commit: commit, method_definition: last_method_commit.method_definition)
          else
            method_definition = nil
            commit.source_files.each do |source_file|
              next unless source_file.source[Regexp.new(method_name)]
              method_finder = MethodFinder.new(source_file: source_file)
              break if method_definition = method_finder.find(method_identifier)
            end
            yielder << last_method_commit if last_method_commit
            last_method_commit = MethodCommit.new(commit: commit, method_definition: method_definition)
            yielder << last_method_commit
          end
        end
      end
    end

    def diffs(method_identifier, max_count: nil)
      Enumerator.new do |yielder|
        history(method_identifier, max_count: max_count).each_cons(2) do |(commit, parent)|
          diff = MethodDiff.new(first_commit: parent, second_commit: commit)
          unless diff.empty?
            yielder << [commit, diff]
          end
        end
      end
    end
  end
end
