require File.expand_path('lib/foreman_salt/version', __dir__)

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
  s.add_dependency 'foreman_remote_execution', '>= 14.0', '< 16'
  s.add_dependency 'foreman-tasks', '>= 10.0', '< 11'
  s.add_development_dependency 'theforeman-rubocop', '~> 0.0.6'
end
