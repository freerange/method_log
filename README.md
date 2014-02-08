## Method Log

Trace the history of an individual method in a git repository.

### Install

    gem install method_log

### Run

    method_log <method-signature> # e.g. Foo::Bar#baz

### Todo

* Support earlier versions of Ruby
* Support class methods
* Support namespaced classes e.g. `class Foo::Bar`
* Support for Rspec tests
* Display method implementation for each commit
* Display diffs in method implementation between commits
* Only display diffs when method implementation has changed
* Default to looking for git repo in current working directory
* Default to looking for commits in current git branch
* Maybe add as new git command or extension to existing command e.g. `git log`
* Optimise search for method definitions:
  * First look in file where method was last defined
  * Simple text search for files containing method name to narrow files that need to be parsed

### Credits

Written by [James Mead](http://jamesmead.org) and the other members of [Go Free Range](http://gofreerange.com).

### License

Released under the [MIT License](https://github.com/freerange/method_log/blob/master/LICENSE).
