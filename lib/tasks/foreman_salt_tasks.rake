namespace :foreman_salt do
  task rubocop: :environment do
    begin
      require 'rubocop/rake_task'
      RuboCop::RakeTask.new(:rubocop_salt) do |task|
        task.patterns = ["#{ForemanSalt::Engine.root}/app/**/*.rb",
                         "#{ForemanSalt::Engine.root}/lib/**/*.rb",
                         "#{ForemanSalt::Engine.root}/test/**/*.rb"]
      end
    rescue StandardError
      puts 'Rubocop not loaded.'
    end

    Rake::Task['rubocop_salt'].invoke
  end
end

namespace :test do
  desc 'Test ForemanSalt'
  Rake::TestTask.new(:foreman_salt) do |t|
    test_dir = File.join(File.dirname(__FILE__), '../..', 'test')
    t.libs << ['test', test_dir]
    t.pattern = "#{test_dir}/**/*_test.rb"
    t.verbose = true
    t.warning = false
  end
end

Rake::Task[:test].enhance ['test:foreman_salt']

load 'tasks/jenkins.rake'
Rake::Task['jenkins:unit'].enhance ['test:foreman_salt', 'foreman_salt:rubocop'] if Rake::Task.task_defined?(:'jenkins:unit')
