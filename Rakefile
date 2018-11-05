# frozen_string_literal: true

begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

require "bundler/gem_tasks"
require "rake/extensiontask"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

task(compile: []) do
  Dir.chdir("ext/enterprise_script_service") do
    sh("../../bin/rake")
  end
end

Rake::Task[:clean].enhance do
  sh("script/mkmruby", "clean")
end

Rake::Task[:clobber].enhance do
  sh("script/mkmruby", "clobber")
end

task(mrproper: []) do
  Dir.chdir("ext/enterprise_script_service") do
    sh("../../bin/rake", "mrproper")
  end
end

task(spec: [:compile])

task(default: [:spec])
