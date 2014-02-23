## Method Log

Trace the history of an individual method in a git repository.

This is a work-in-progress and nowhere near production-ready.

### Dependencies

* Ruby >= v2.0.0 (just because I'm using named parameters)
* The [rugged](https://github.com/libgit2/rugged) Ruby gem (listed as dependency in gemspec)
* The [libgit2](https://github.com/libgit2/libgit2) C library (included as part of rugged gem)

### Install

    gem install method_log

### Run

    method_log <method-signature> # e.g. Foo::Bar#baz

### Todo

* Support earlier versions of Ruby (it ought to be possible to support down to v1.9.3 fairly easily)
* Support for Rspec tests
* Default to looking for commits in current git branch
* Maybe add as new git command or extension to existing command e.g. `git log`
* Optimise search for method definitions:
  * Only consider commits where file that last contained method has changed
  * First look in file where method was last defined
* By default stop when method disappears from history
* Find "similar" method implementations e.g. by comparing ASTs of implementations

### Credits

Written by [James Mead](http://jamesmead.org) and the other members of [Go Free Range](http://gofreerange.com).

Thanks to Michael Feathers for some ideas in [delta-flora](https://github.com/michaelfeathers/delta-flora).

Thanks to [TICOSA](http://ticosa.org/) for giving me the impetus to do something about an idea I'd been kicking around for a while.

### License

Released under the [MIT License](https://github.com/freerange/method_log/blob/master/LICENSE).
