lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'method_log/version'

Gem::Specification.new do |s|
  s.name     = 'method_log'
  s.version  = MethodLog::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors  = ['James Mead']
  s.email    = ['james@floehopper.org']
  s.homepage = 'http://jamesmead.org'
  s.summary  = 'Trace the history of an individual method in a git repository.'
  s.license  = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'rugged'
  s.add_dependency 'parser'
  s.add_dependency 'diffy'
  s.add_dependency 'trollop'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
