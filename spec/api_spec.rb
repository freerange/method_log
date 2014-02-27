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
      repository = Repository.new(path: repository_path)
      commit_1 = repository.commit(source(path: 'foo.rb', source: %{
        class Foo
          def bar
            # implementation 1
          end
        end
      }))
      commit_2 = repository.commit(source(path: 'foo.rb', source: %{
        # move method definition down one line
        class Foo
          def bar
            # implementation 2
          end
        end
      }))

      api = API.new(repository: Repository.new(path: repository_path))
      method_commit, method_diff = api.diffs('Foo#bar').first

      expect(method_commit.sha).to eq(commit_2.sha)
      expect(method_diff.to_s.chomp).to eq(unindent(%{
           def bar
        -    # implementation 1
        +    # implementation 2
           end
      }))
    end

    it 'finds method which is defined in one commit, then removed in the next commit, and defined again in the next commit' do
      repository = Repository.new(path: repository_path)
      commit_1 = repository.commit(source(path: 'foo.rb', source: %{
        class Foo
          def bar; end
        end
      }))
      commit_2 = repository.commit(source(path: 'foo.rb', source: %{
        class Foo
        end
      }))
      commit_3 = repository.commit(source(path: 'foo.rb', source: %{
        class Foo
          def bar; end
        end
      }))

      api = API.new(repository: Repository.new(path: repository_path))
      diffs = api.diffs('Foo#bar').map(&:last).map(&:to_s)
      expect(diffs).to eq([
        "+  def bar; end\n",
        "-  def bar; end\n"
      ])
    end
  end
end