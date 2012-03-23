require 'rubygems/create/builder'
require 'erb'
require 'fileutils'

class Gem::Commands::CreateCommand < Gem::Command
  TEMPLATES = File.expand_path('../../create/templates', __FILE__)

  def initialize
    super "create", "Create a new gem"
    add_options!
  end

  def execute
    render!
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

  def render!
    manifest[:directories].each do |dir|
      FileUtils.mkdir_p dir.gsub('gem_name', name)
    end

    manifest[:files].each do |file|
      dest = file.gsub('gem_name', name).gsub(/\.erb$/, '')
      write_template_file(file, dest)
    end
  end

  def manifest
    @manifest ||= Hash.new.tap do |h|
      Dir.chdir TEMPLATES do
        templates       = Dir["**/*"]
        h[:files]       = templates.reject { |t| File.directory?(t) }
        h[:directories] = templates.select { |t| File.directory?(t) }
      end
    end
  end

  def write_template_file(source, dest)
    s = render_file(source)
    File.open(dest, "w") { |file| file.puts s }
  end

  def render_file(file)
    ERB.new(read_file(file)).result(builder.get_binding)
  end

  def read_file(file)
    Dir.chdir TEMPLATES do
      if File.exists?(file)
        File.read(file)
      else
        raise "Template #{file.inspect} doesnt exist!"
      end
    end
  end

  def builder
    @builder ||= Gem::Create::Builder.new(get_one_gem_name, options)
  end

  def name
    builder.name
  end
end
