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
        last_source_file = nil
        @repository.commits(max_count: max_count).each do |commit|
          next if last_source_file && commit.contains?(last_source_file)
          source_files = commit.source_files.select { |sf| sf.source[Regexp.new(method_name)] }
          method_definition = nil
          source_files.map { |sf| MethodFinder.new(source_file: sf) }.each do |method_finder|
            break if method_definition = method_finder.find(method_identifier)
          end
          last_source_file = method_definition && method_definition.source_file
          yielder << MethodCommit.new(commit: commit, method_definition: method_definition)
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
