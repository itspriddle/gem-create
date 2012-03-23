require 'rake/testtask'

task :default => :spec

Rake::TestTask.new :spec do |test|
  test.libs << "spec"
  test.pattern = "spec/*_spec.rb"
  test.verbose = ENV.has_key?('VERBOSE')
end
