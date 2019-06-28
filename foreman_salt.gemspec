require File.expand_path('../lib/foreman_salt/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'foreman_salt'
  s.version     = ForemanSalt::VERSION
  s.licenses    = ['GPL-3.0']
  s.authors     = ['Stephen Benjamin']
  s.email       = ['stephen@redhat.com']
  s.homepage    = 'https://github.com/theforeman/foreman_salt'
  s.summary     = 'Foreman Plug-in for Salt'
  s.description = 'Foreman Plug-in for Salt'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'deface', '< 2.0'
  s.add_dependency 'foreman-tasks', '~> 0.8'
  s.add_dependency 'foreman_remote_execution', '~> 1.8.0'
  s.add_development_dependency 'rubocop', '~> 0.71.0'
end
