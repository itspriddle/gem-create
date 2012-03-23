require 'spec_helper'

describe Gem::Commands::CreateCommand do
  it "prints help" do
    out, err = run_command('--help')
    err.must_equal "", "should not write to STDERR"

    out.must_match "Usage: gem create GEM_NAME [options]"
    out.must_match "--force"
    out.must_match "--git"
    out.must_match "--author"
    out.must_match "--github-name"
    out.must_match "--email"
    out.must_match "--template-directory"
  end

  describe "generated files" do
    before do
      run_command *%W(
        some_gem
        --author Bender\ Rodriguez
        --email bender@planex.com
        --github bender
      )
    end

    it_renders "README.markdown" do |data|
      data.must_match "# SomeGem [![SomeGem Build Status"
      data.must_match "https://secure.travis-ci.org/bender/some_gem.png?branch=master"
      data.must_match "http://travis-ci.org/bender/some_gem"
      data.must_match "Copyright (c) #{Time.now.year} Bender Rodriguez"
    end

    it_renders "LICENSE" do |data|
      data.must_match "Copyright (c) #{Time.now.year} Bender Rodriguez <bender@planex.com>"
    end

    it_renders "some_gem.gemspec" do |data|
      data.must_match %r{require "some_gem/version}
      data.must_match %r{s\.version\s*= SomeGem::Version}
      data.must_match %r{s\.name\s*= "some_gem"}
      data.must_match %r{s\.summary\s*= "SomeGem: Description here"}
      data.must_match %r{s\.homepage\s*= "https://github\.com/bender/some_gem"}
      data.must_match %r{s\.authors\s*= \["Bender Rodriguez"\]}
      data.must_match %r{s\.email\s*= "bender@planex\.com"}
    end

    it_renders "lib/some_gem.rb" do |data|
      data.must_match 'require "some_gem/version"'
    end

    it_renders "lib/some_gem/version.rb" do |data|
      data.must_match "module SomeGem"
      data.must_match "  VERSION = Version = '0.0.0'"
    end

    it_renders "spec/spec_helper.rb"

    it_renders "spec/some_gem_spec.rb"

    it_renders "Rakefile"

    it_renders "Gemfile"

    it_renders ".travis.yml" do |data|
      data.must_match "recipients:\n      - bender@planex.com"
    end
  end

  describe "custom template directory" do
    it "raises with a non-existing directory" do
      proc { run_command *%W(some_gem --template-dir /dev/null/asdf) }.
        must_raise RuntimeError, 'Directory "/dev/null/asdf" doesn\'t exist!'
    end
  end
end
