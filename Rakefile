require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = Dir['test/**/*_test.rb']
end
task default: :test

desc "Open a pry console preloaded with this library"
task console: 'console:pry'

namespace :console do

  task :pry do
    sh "bundle exec pry -I lib -r html2confluence.rb"
  end

  task :irb do
    sh "bundle exec irb -I lib -r html2confluence.rb"
  end

end
