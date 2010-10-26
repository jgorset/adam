require 'rake'
require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

desc "Run tests"
Rake::TestTask.new do |t|
  t.pattern = "test/unit/*_test.rb"
  t.verbose = true
  t.warning = true
end
