module Gem::Create
  # The Builder class is used to provide variables in ERB templates.
  class Builder
    # The name of the gem.
    attr_reader :name

    # The options supplied to the command line.
    attr_reader :options

    # Creates a new Builder
    #
    # name    - The name of the gem.
    # options - The options used to create the gem.
    def initialize(name, options = {})
      @options = options
      @name    = name
    end

    # Returns the binding of this object.
    def get_binding
      binding
    end

    # Returns the gem author's name.
    def author
      options[:author] || git_config('user.name')
    end

    # Returns the gem author's email address.
    def email
      options[:email] || git_config('user.email')
    end

    # Returns the gem author's Github username.
    def github_name
      options[:github_name] || git_config('github.user')
    end

    # Returns the given variable from `git config`
    #
    # key - The key to query.
    #
    # Returns a String.
    def git_config(key)
      %x{#{git} config --global #{key} 2> /dev/null}.chomp.strip
    end

    # The path to git.
    def git
      options[:git] || "git"
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
end
