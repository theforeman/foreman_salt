require File.expand_path('../lib/foreman_salt/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "foreman_salt"
  s.version     = ForemanSalt::VERSION
  s.licenses    = ['GPL-3']
  s.authors     = ["Stephen Benjamin"]
  s.email       = ["stephen@redhat.com"]
  s.homepage    = "http://github.com/theforeman/foreman_salt"
  s.summary     = "Foreman Plug-in for Salt"
  s.description = "Foreman Plug-in for Salt"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'deface', '< 1.0'
end
