require 'rubygems/create/builder'
require 'erb'
require 'fileutils'

class Gem::Commands::CreateCommand < Gem::Command
  TEMPLATES = File.expand_path('../../create/templates', __FILE__)

  def initialize
    super "create", "Creates a new RubyGem skeleton"
    add_options!
  end

  def execute
    create_gem!
  end

  def usage
    "gem create GEM_NAME"
  end

  private

  def add_options!
    add_option "--force", "Overwrite existing files" do |force, options|
      options[:force] = !! force
    end

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

    add_option "--template-directory DIR", "A custom template directory to use" do |directory, options|
      if File.directory?(directory)
        options[:template_directory] = directory
      else
        raise "Directory #{directory.inspect} doesn't exist!"
      end
    end
  end

  def create_gem!
    manifest[:directories].each do |dir|
      FileUtils.mkdir_p dir.gsub('gem_name', builder.name)
    end

    manifest[:files].each do |file|
      dest = file.gsub('gem_name', builder.name).gsub(/\.erb$/, '')
      write_template_file(file, dest)
    end
  end

  def force?
    options[:force]
  end

  def template_dir
    dir = options[:template_directory] || TEMPLATES
    Dir.chdir(dir) { return yield } if block_given?
    dir
  end

  def manifest
    @manifest ||= Hash.new.tap do |h|
      template_dir do
        templates       = Dir["**/*"]
        h[:files]       = templates.reject { |t| File.directory?(t) }
        h[:directories] = templates.select { |t| File.directory?(t) }
      end
    end
  end

  def write_template_file(source, dest)
    if can_write_file?(dest)
      s = render_file(source)
      File.open(dest, "w") { |file| file.puts s }
    else
      raise "Can't create #{dest.inspect} as it already exists!"
    end
  end

  def can_write_file?(file)
    force? || ! File.exists?(file)
  end

  def render_file(file)
    ERB.new(read_file(file)).result(builder.get_binding)
  end

  def read_file(file)
    template_dir do
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
end
