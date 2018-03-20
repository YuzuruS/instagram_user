require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'coveralls/rake/task'

RSpec::Core::RakeTask.new(:rspec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['-cfd --backtrace']
end

Coveralls::RakeTask.new

task :default => ["rspec", "style"]
task :ci => ["rspec", "style", "coveralls:push"]