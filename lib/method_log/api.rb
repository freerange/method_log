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
        @repository.commits(max_count: max_count).each do |commit|
          source_files = commit.source_files.select { |sf| sf.source[Regexp.new(method_name)] }
          method_definitions = source_files.inject([]) do |definitions, source_file|
            method_finder = MethodFinder.new(source_file: source_file)
            definitions += Array(method_finder.find(method_identifier))
          end
          yielder << MethodCommit.new(commit: commit, method_definition: method_definitions.first)
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
