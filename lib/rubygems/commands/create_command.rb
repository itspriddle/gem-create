require 'yaml'
require 'erb'
require 'fileutils'

# This class facilitates the `gem create` command.
class Gem::Commands::CreateCommand < Gem::Command
  IDENTIFIER = '%gem_name%'.freeze

  class Builder
    attr_reader :name

    def initialize(name, params = {})
      @name = name.to_s

      params.each do |(key, value)|
        self.class.send(:define_method, key) do
          value.respond_to?(:gsub) ? value.gsub(IDENTIFIER, @name) : value
        end
      end
    end

    # The path of the gem.
    def path
      name.gsub('-', '/')
    end

    # The class name of the gem in CamelCase.
    def gem_class
      name.split('-').map { |seg| seg.gsub(/(?:^|_| )(.)/) { $1.upcase } }.join('::')
    end
  end

  # Initializes the plugin.
  def initialize
    super "create", "Creates a new RubyGem skeleton"
    add_options!
  end

  # Creates the gem.
  def execute
    @gem_name = get_one_gem_name

    create_gem!
  end

  # The usage banner displayed for `gem create --help`.
  def usage
    "gem create GEM_NAME"
  end

  def defaults_str
    '--template-directory ~/.gem/skel --data-file ~/.gem/skel.yml'
  end

  private

  # Private: Adds command line switches used by this plugin.
  def add_options!
    add_option "-f", "--force", "Overwrite existing files" do |v, options|
      options[:force] = true
    end

    add_option "-d", "--destination-directory PATH", "Destination directory,",
                                                     "$PWD/GEM_NAME by default" do |directory, options|
      options[:destination_directory] = directory
    end
#
#     add_option "-n", "--dry-run", "Don't actually create any files, ",
#                                   "just show what would be created" do |v, options|
#       options[:dry_run] = true
#     end

    add_option :Skeleton, "--template-directory PATH", "A custom template directory to use" do |directory, options|
      if File.directory?(directory)
        options[:template_directory] = directory
      else
        raise "Directory #{directory.inspect} doesn't exist!"
      end
    end

    add_option :Skeleton, "--data-file PATH", "Path to a YAML file containing",
                                              "variables that will be available",
                                              "in all template files" do |file, options|
      file = File.expand_path(file)

      if File.exists?(file)
        options[:data_file] = file
      else
        raise "File #{file.inspect} doesn't exist!"
      end
    end
  end

  # Private: Creates the gem skeleton within the destination directory.
  #
  # Creates any required directories, renders templates via ERB, and finally,
  # writes new files.
  #
  # When creating directories and files, any occurrence of 'gem_name' is
  # replaced with the name of the gem to be created.
  def create_gem!
    unless File.directory?(destination_directory)
      FileUtils.mkdir_p(destination_directory)
    end

    Dir.chdir(destination_directory) do
      manifest.each do |file|
        dest = file.gsub(IDENTIFIER, @gem_name)
        base = File.dirname(dest)

        FileUtils.mkdir_p(base) unless File.directory?(base)

        write_template_file(file, dest)
      end
    end
  end

  # Private: Returns true if files should be overwritten when creating the new
  # gem.
  #
  # Returns true or false.
  def force?
    !! options[:force]
  end

  # Private: The directory to create the new gem in.
  #
  # Defaults to `Dir.pwd`.
  def destination_directory
    File.expand_path(options[:destination_directory] || File.join(Dir.pwd, @gem_name))
  end

  # Private: The directory containing template files for the new gem.
  #
  # Defaults to `~/.gem/skel/`.
  #
  # Returns a String.
  def template_directory
    File.expand_path(options[:template_directory] || "~/.gem/skel")
  end

  # Private: The file containing variables which will be made available in
  # template files.
  #
  # Defaults to `~/.gem/skel.yml`.
  #
  # Returns a String.
  def data_file
    File.expand_path(options[:data_file] || "~/.gem/skel.yml")
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
  def in_template_directory
    Dir.chdir(template_directory) { return yield }
  end

  # Private: An Array containing files to create.
  #
  # Returns an Array.
  def manifest
    @manifest ||= in_template_directory do
      Dir.glob("**/*", File::FNM_DOTMATCH).reject { |t| File.directory?(t) }
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

  # Private: Returns true if the given file can be written.
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
    data = in_template_directory { File.read(file) }
    ERB.new(data).result(builder.send(:binding))
  end

  # Private: Creates/returns a Gem::Create::Builder instance. This will be
  # used to provide variables in template files.
  #
  # Returns a Gem::Create::Builder instance.
  def builder
    return @builder if @builder
    attributes = YAML.load_file(data_file).merge(:gem_name => @gem_name)
    @builder   = Builder.new(@gem_name, attributes)
  end
end
