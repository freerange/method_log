## Method Log [![Build Status](https://travis-ci.org/freerange/method_log.svg?branch=master)](https://travis-ci.org/freerange/method_log) [![Gem Version](https://badge.fury.io/rb/method_log.svg)](https://badge.fury.io/rb/method_log)

Trace the history of an individual method in a git repository (experimental).

See [this article](https://gofreerange.com/tracing-the-git-history-of-a-ruby-method) for more information.

### Requirements

* Tool runtime: Ruby >= v2.0.0
* Source code under analysis: Ruby >= v1.8

### Install

    gem install method_log

### Run

#### Display the commit history for a single method

    $ method_log [options] <method-signature>

#### Build a parallel git repository of method definitions

    $ build_methods_repo [options] <source-repo-path> <target-repo-path>

### Credits

Written by [James Mead](http://jamesmead.org) and the other members of [Go Free Range](http://gofreerange.com).

Thanks to Michael Feathers for some ideas in [delta-flora](https://github.com/michaelfeathers/delta-flora).

Thanks to [TICOSA](http://ticosa.org/) for giving me the impetus to do something about an idea I'd been kicking around for a while.

### License

Released under the [MIT License](https://github.com/freerange/method_log/blob/master/LICENSE).
