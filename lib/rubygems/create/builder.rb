require 'erb'
require 'fileutils'

module Gem::Create
  class Builder
    TEMPLATES = File.expand_path('../templates', __FILE__)

    attr_reader :name, :options

    def initialize(name, parent_klass)
      @options = parent_klass.options
      @name    = name
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

    private

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
      ERB.new(read_file(file)).result(binding)
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

    def author
      options[:author] || git_config('user.name')
    end

    def email
      options[:email] || git_config('user.email')
    end

    def github_name
      options[:github_name] || git_config('github.user')
    end

    def git_config(key)
      %x{#{git} config --global #{key} 2> /dev/null}.chomp.strip
    end

    def git
      options[:git] || "git"
    end

    def path
      name.gsub('-', '/')
    end

    def gem_class
      name.split('-').map { |seg| seg.gsub(/(?:^|_| )(.)/) { $1.upcase } }.join('::')
    end

  end
end
