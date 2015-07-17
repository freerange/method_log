require 'bundler/setup'

require 'method_log/repository'
require 'method_log/method_finder'
require 'method_log/source_file'

def unindent(code)
  lines = code.split($/)
  indent = lines.reject { |l| l.strip.length == 0 }.map { |l| l[/^ */].length }.min
  lines.map { |l| l.sub(Regexp.new(' ' * indent), '') }.join($/)
end

repository_path = File.expand_path('../..')
rugged_repository = Rugged::Repository.new(repository_path)
exit unless rugged_repository.head.name == 'refs/heads/master'
last_commit_sha = rugged_repository.last_commit.oid

repository = MethodLog::Repository.new(repository_path)
last_commit = repository.build_commit(last_commit_sha)

rugged_repository.checkout('method-log')
begin
  new_commit = repository.build_commit
  last_commit.source_files.each do |source_file|
    next if source_file.path[%r{^(vendor|test)}]
    begin
      method_finder = MethodLog::MethodFinder.new(source_file)
      method_finder.instance_variable_get('@methods').each do |method_signature, method_definition|
        _, namespace, name = method_signature.match(/^(.*)([#.].*)$/).to_a
        path = namespace.split('::').push(name).join(File::SEPARATOR) + '.rb'
        new_commit.add(MethodLog::SourceFile.new(path: path, source: unindent(method_definition.source) + $/))
      end
    rescue Parser::SyntaxError => e
      p e
    end
  end
  new_commit.apply(user: last_commit.author, message: last_commit.message)
  rugged_repository.reset('HEAD', :hard)
ensure
  rugged_repository.checkout('master')
end
