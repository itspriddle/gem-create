module Gem::Create
  class Builder
    attr_reader :name, :options

    def initialize(name, options = {})
      @options = options
      @name    = name
    end

    def get_binding
      binding
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
