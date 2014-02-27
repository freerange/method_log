require 'spec_helper'

require 'method_log/api'
require 'method_log/source_file'
require 'method_log/repository'
require 'method_log/commit'
require 'method_log/method_definition'
require 'method_log/method_commit'

module MethodLog
  describe API do
    let(:repository_path) { File.expand_path('../repository.git', __FILE__) }

    before do
      FileUtils.mkdir_p(repository_path)
      Rugged::Repository.init_at(repository_path, :bare)
    end

    after do
      FileUtils.rm_rf(repository_path)
    end

    it 'finds class instance method in repository with two commits with single source file' do
      foo_1 = source(path: 'foo.rb', source: %{
        class Foo
          def bar
            # implementation 1
          end
        end
      })

      foo_2 = source(path: 'foo.rb', source: %{
        # move method definition down one line
        class Foo
          def bar
            # implementation 2
          end
        end
      })

      repository = Repository.new(path: repository_path)
      commit_1 = repository.commit(foo_1)
      commit_2 = repository.commit(foo_2)

      repository = Repository.new(path: repository_path)
      api = API.new(repository: repository)
      method_commits = api.history('Foo#bar').to_a

      method_definition_1 = MethodDefinition.new(source_file: foo_1, lines: 1..3)
      method_definition_2 = MethodDefinition.new(source_file: foo_2, lines: 2..4)

      method_commit_1 = MethodCommit.new(commit: commit_1, method_definition: method_definition_1)
      method_commit_2 = MethodCommit.new(commit: commit_2, method_definition: method_definition_2)

      expect(method_commits).to eq([method_commit_2, method_commit_1])

      method_commit, method_diff = api.diffs('Foo#bar').first
      expect(method_diff.to_s.chomp).to eq(unindent(%{
           def bar
        -    # implementation 1
        +    # implementation 2
           end
      }))
    end

    it 'finds method which is defined in one commit, then removed in the next commit, and defined again in the next commit' do
      foo_with_bar = source(path: 'foo.rb', source: %{
        class Foo
          def bar; end
        end
      })

      foo_without_bar = source(path: 'foo.rb', source: %{
        class Foo
        end
      })

      repository = Repository.new(path: repository_path)
      commit_1 = repository.commit(foo_with_bar)
      commit_2 = repository.commit(foo_without_bar)
      commit_3 = repository.commit(foo_with_bar)

      repository = Repository.new(path: repository_path)
      api = API.new(repository: repository)
      diffs = api.diffs('Foo#bar').map(&:last).map(&:to_s)
      expect(diffs).to eq([
        "+  def bar; end\n",
        "-  def bar; end\n"
      ])
    end
  end
end