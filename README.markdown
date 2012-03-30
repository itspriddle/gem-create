# gem-create [![`gem-create` Build Status][Build Icon]][Build Status]

> This is my gem template. There are many like it, but this one is mine.

`gem-create` provides a `gem create` command which can be used to generate a
skeleton for a new RubyGem.

[Build Icon]: https://secure.travis-ci.org/itspriddle/gem-create.png?branch=master
[Build Status]: http://travis-ci.org/itspriddle/gem-create

## Setup

First, install the gem:

    gem install gem-create

Next, create a data file. By default this is in `~/.gem/skel.yml`. This file
contains variables that will be available in your template files. It **must**
be a valid YAML file.

The following default variables are available in addition to any supplied in
your data file:

    name      # the name of the gem (eg: my_gem)
    gem_class # the class name of the gem (eg: MyGem)

See `spec/fixtures/skel.yml` in this repo for an example data file.

Next, create your gem skeleton. By default this is in `~/.gem/skel`. This
directory contains files/directories that will be copied when creating a new
gem. Files are rendered via ERB and may utilize the variables set in your data
file (eg: `<%= github_name %>`).

Any file/directory with `%gem_name%` in it's path will be renamed when the new
gem is created. Eg (assume `gem create my_new_gem`):

    some/%gem_name% => some/my_new_gem
    some/gem_name   => some/gem_name

See `spec/fixtures/skel` in this repo for an example gem skeleton.

## Usage

    Usage: gem create GEM_NAME [options]

      Options:
        -f, --force                      Overwrite existing files


      Skeleton Options:
            --template-directory DIR     A custom template directory to use
            --data-file PATH             Path to a YAML file containing
                                         variables that will be available
                                         in all template files


      Common Options:
        -h, --help                       Get help on this command
        -V, --[no-]verbose               Set the verbose level of output
        -q, --quiet                      Silence commands
            --config-file FILE           Use this config file instead of default
            --backtrace                  Show stack backtrace on errors
            --debug                      Turn on Ruby debugging


      Summary:
        Creates a new RubyGem skeleton

      Defaults:
        --template-directory ~/.gem/skel --data-file ~/.gem/skel.yml

## Customization

If `~/.gem/skel` and `~/.gem/skel.yml` don't work for you, you can customize
them in `~/.gemrc`:

    create: --template-directory ~/code/gem-template --data-file ~/code/gem-template-data.yml

## Development

`gem-create` depends on rake and minitest for testing.

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
