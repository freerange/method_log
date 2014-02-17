require 'method_log/method_finder'
require 'method_log/method_commit'

module MethodLog
  class API
    def initialize(repository: nil)
      @repository = repository
    end

    def history(method_identifier)
      Enumerator.new do |yielder|
        @repository.commits.each do |commit|
          method_definitions = commit.source_files.inject([]) do |definitions, source_file|
            method_finder = MethodFinder.new(source_file: source_file)
            definitions += Array(method_finder.find(method_identifier))
          end
          yielder << MethodCommit.new(commit: commit, method_definition: method_definitions.first)
        end
      end
    end
  end
end
