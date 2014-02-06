require 'method_log/method_finder'
require 'method_log/method_commit'

module MethodLog
  class API
    def initialize(repository:)
      @repository = repository
    end

    def history(method_identifier)
      @repository.commits.map do |commit|
        method_definitions = commit.source_files.inject([]) do |definitions, source_file|
          method_finder = MethodFinder.new(source_file: source_file)
          definitions += Array(method_finder.find(method_identifier))
        end
        MethodCommit.new(commit: commit, method_definition: method_definitions.first)
      end
    end
  end
end
