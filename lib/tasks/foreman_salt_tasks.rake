namespace :foreman_salt do
  task :rubocop do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_salt) do |task|
        task.patterns = ["#{ForemanSalt::Engine.root}/app/**/*.rb",
                         "#{ForemanSalt::Engine.root}/lib/**/*.rb",
                         "#{ForemanSalt::Engine.root}/test/**/*.rb"]
      end
    rescue
      puts "Rubocop not loaded."
    end

    Rake::Task['rubocop_salt'].invoke
  end
end

namespace :test do
  desc 'Test ForemanSalt'
  Rake::TestTask.new(:foreman_salt) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test',test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
  end
end

Rake::Task[:test].enhance do
  Rake::Task['test:foreman_salt'].invoke
end

load 'tasks/jenkins.rake'
if Rake::Task.task_defined?(:'jenkins:unit')
  Rake::Task['jenkins:unit'].enhance do
    Rake::Task['test:foreman_salt'].invoke
    Rake::Task['foreman_salt:rubocop'].invoke
  end
end
