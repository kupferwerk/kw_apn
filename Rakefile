require 'rubygems'
require 'rake'

task :gem do
  `gem build *.gemspec`
end

task :install do
  Rake::Task[:gem].invoke
  `sudo gem install *.gem`
  Rake::Task[:cleanup].invoke
end

task :cleanup do
  `rm *.gem`
end