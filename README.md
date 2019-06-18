## Method Log

Trace the history of an individual method in a git repository (experimental).

### Requirements

* Ruby >= v2.0.0 (due to requirements of the `parser` gem); although parsing of source code for Ruby >= v1.8 is possible
* The [rugged](https://github.com/libgit2/rugged) Ruby gem (listed as dependency in gemspec)
* The [libgit2](https://github.com/libgit2/libgit2) C library (included as part of rugged gem)
* The [parser](https://github.com/whitequark/parser) Ruby gem (listed as dependency in gemspec)

### Install

    gem install method_log

### Run

#### Display the commit history for a single method

    $ method_log [options] <method-signature>

#### Build a parallel git repository of method definitions

    $ build_methods_repo [options] <source-repo-path> <target-repo-path>

### To Do

* Parsing support for RSpec tests
* Default to looking for commits in current git branch
* Check what happens with merge commits
* Maybe add as new git command or extension to existing command e.g. `git log`
* Find "similar" method implementations e.g. by comparing ASTs of implementations

### Credits

Written by [James Mead](http://jamesmead.org) and the other members of [Go Free Range](http://gofreerange.com).

Thanks to Michael Feathers for some ideas in [delta-flora](https://github.com/michaelfeathers/delta-flora).

Thanks to [TICOSA](http://ticosa.org/) for giving me the impetus to do something about an idea I'd been kicking around for a while.

### License

Released under the [MIT License](https://github.com/freerange/method_log/blob/master/LICENSE).
