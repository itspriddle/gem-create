$:.unshift 'lib'

Gem::Specification.new do |s|
  s.platform   = Gem::Platform::RUBY
  s.name       = "gem-create"
  s.version    = "0.1.0"
  s.date       = Time.now.strftime('%Y-%m-%d')
  s.homepage   = "https://github.com/itspriddle/gem-create"
  s.authors    = ["Joshua Priddle"]
  s.email      = "jpriddle@me.com"
  s.summary    = "gem create: create a new gem"

  s.files      = %w[ Gemfile Rakefile README.markdown gem-create.gemspec LICENSE ]
  s.files     += Dir['lib/**/*']
  s.test_files = Dir['spec/**/*']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
end
