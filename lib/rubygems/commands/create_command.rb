require 'rubygems/create/builder'

class Gem::Commands::CreateCommand < Gem::Command

  def initialize
    super "create", "Create a new gem"
    add_options!
  end

  def execute
    builder = Gem::Create::Builder.new(get_one_gem_name, self)
    builder.render!
  end

  private

  def add_options!
    add_option "--git GIT_PATH", "The path to git" do |git, options|
      options[:git] = git
    end

    add_option "--author AUTHOR", "The author name used in gemspec" do |author, options|
      options[:author] = author
    end

    add_option "--github-name NAME", "The Github account that will own the gem" do |github, options|
      options[:github_name] = github
    end

    add_option "--email EMAIL", "The author's email address used in gemspec" do |email, options|
      options[:email] = email
    end
  end
end
