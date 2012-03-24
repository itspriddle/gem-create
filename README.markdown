# Gem::Create [![Gem::Create Build Status][Build Icon]][Build Status]

> This is my gem template. There are many like it, but this one is mine.

Gem::Create provides a `gem create` command which can be used to generate a
skeleton for a new RubyGem.

[Build Icon]: https://secure.travis-ci.org/itspriddle/gem-create.png?branch=master
[Build Status]: http://travis-ci.org/itspriddle/gem-create

## Usage

    Usage: gem create GEM_NAME [options]

      Options:
            --force                      Overwrite existing files
            --git GIT_PATH               The path to git
            --author AUTHOR              The author name used in gemspec
            --github-name NAME           The Github account that will own the gem
            --email EMAIL                The author's email address used in gemspec
            --template-directory DIR     A custom template directory to use


      Common Options:
        -h, --help                       Get help on this command
        -V, --[no-]verbose               Set the verbose level of output
        -q, --quiet                      Silence commands
            --config-file FILE           Use this config file instead of default
            --backtrace                  Show stack backtrace on errors
            --debug                      Turn on Ruby debugging


      Summary:
        Creates a new RubyGem skeleton

## Development

Gem::Create depends on rake and minitest for testing.

    git clone git://github.com/itspriddle/gem-create
    cd gem-create
    bundle install
    bundle exec rake spec

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version
  unintentionally.
* Commit, do not bump version. (If you want to have your own version, that is
  fine but bump version in a commit by itself I can ignore when I pull).
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2012 Joshua Priddle. See LICENSE for details.
