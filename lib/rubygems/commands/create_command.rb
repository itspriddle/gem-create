require 'rubygems/create/builder'
require 'erb'
require 'fileutils'

# The Gem::Commands::CreateCommand class facilitates the `gem create` command.
class Gem::Commands::CreateCommand < Gem::Command

  # Default path to templates provided by this plugin.
  TEMPLATES = File.expand_path('../../create/templates', __FILE__)

  # Initializes the plugin.
  def initialize
    super "create", "Creates a new RubyGem skeleton"
    add_options!
  end

  # Creates the gem.
  def execute
    create_gem!
  end

  # The usage banner displayed for `gem create --help`.
  def usage
    "gem create GEM_NAME"
  end

  private

  # Private: Adds command line switches used by this plugin.
  def add_options!
    add_option "--force", "Overwrite existing files" do |force, options|
      options[:force] = force
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

  # Private: Creates the gem skeleton.
  #
  # First any requires directories are created. Then, templates are rendered
  # via ERB and written as new files.
  #
  # When creating directories and files, any occurrence of 'gem_name' is
  # replaced with the name of the gem to be created.
  def create_gem!
    manifest[:directories].each do |dir|
      FileUtils.mkdir_p dir.gsub('gem_name', builder.name)
    end

    manifest[:files].each do |file|
      dest = file.gsub('gem_name', builder.name).gsub(/\.erb$/, '')
      write_template_file(file, dest)
    end
  end

  # Private: Returns true if files should be overwritten when creating the new
  # gem.
  #
  # Returns true or false.
  def force?
    !! options[:force]
  end

  # Private: The directory that contains template files to use when creating
  # the new gem. By default, this is TEMPLATES. A user can specify their own
  # directory with the `--template-directory` command line option.
  #
  # If a block is supplied, it is called within the template directory (i.e.
  # Dir.pwd in the block will be set to the template directory), and the value
  # of this block is returned.
  #
  # If no block is supplied, the String template directory is returned.
  def template_dir
    dir = options[:template_directory] || TEMPLATES
    Dir.chdir(dir) { return yield } if block_given?
    dir
  end

  # Private: A Hash containing :files and :directories to create.
  #
  # :files       - An Array of files that will be created.
  # :directories - An Array of directories that will be created.
  #
  # Returns a Hash.
  def manifest
    @manifest ||= Hash.new.tap do |h|
      template_dir do
        templates       = Dir.glob("**/*", File::FNM_DOTMATCH).reject { |t| t =~ /\.\.?$/ }
        h[:files]       = templates.reject { |t| File.directory?(t) }
        h[:directories] = templates.select { |t| File.directory?(t) }
      end
    end
  end

  # Private: Writes a new file from a template.
  #
  # source - Path to the source template.
  # dest   - Path to the destination file.
  def write_template_file(source, dest)
    if can_write_file?(dest)
      s = render_file(source)
      File.open(dest, "w") { |file| file.puts s }
    else
      raise "Can't create #{dest.inspect} as it already exists!"
    end
  end

  # Returns true if the given file can be written.
  #
  # A file can be written if the user specified `--force` via the command
  # line, or the file does not yet exist.
  #
  # file - Path to the file to check.
  #
  # Returns true or false.
  def can_write_file?(file)
    force? || ! File.exists?(file)
  end

  # Private: Renders a file via ERB within the context of a
  # Gem::Create::Builder instance. This makes methods in that class available
  # in the template.
  #
  # file - Path to the template file.
  #
  # Returns the rendered template as a String.
  def render_file(file)
    ERB.new(read_file(file)).result(builder.get_binding)
  end

  # Private: Gets the content from the specified file.
  #
  # file - Path to the file to read.
  #
  # Raises RuntimeError if the file doesn't exist.
  #
  # Returns a String.
  def read_file(file)
    template_dir do
      if File.exists?(file)
        File.read(file)
      else
        raise "Template #{file.inspect} doesnt exist!"
      end
    end
  end

  # Private: Creates/returns a Gem::Create::Builder instance. This will be
  # used to provide variables in template files.
  #
  # Returns a Gem::Create::Builder instance.
  def builder
    @builder ||= Gem::Create::Builder.new(get_one_gem_name, options)
  end
end
