require 'bundler'
Bundler::GemHelper.install_tasks

namespace :box do
  desc 'Adds test vagrant box.'
  task :add do
    sh 'bundle exec vagrant box add --name vultr ./box/vultr.box'
  end

  desc 'Removes testing vagrant box.'
  task :remove do
    sh 'bundle exec vagrant box remove vultr'
  end
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new
