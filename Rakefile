require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cleanerupper"
    gem.summary = "Simple database sanitation"
    gem.email = "mike@fluidmedia.com"
    gem.homepage = "http://github.com/fmiopensource/cleanerupper"
    gem.authors = ["Mike Trpcic"]
    gem.files = FileList['./**/*.*']
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with 'sudo gem install jeweler'"
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the cleanerupper plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the cleanerupper plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Cleanerupper'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
