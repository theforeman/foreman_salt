# -*- coding: utf-8 -*-
require File.expand_path('../lib/foreman_salt_core/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_salt_core'
  s.version     = ForemanSaltCore::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['Adam Ruzicka']
  s.email       = ['aruzicka@redhat.com']
  s.homepage    = 'https://github.com/theforeman/foreman_salt'
  s.summary     = 'Foreman salt - core bits'
  s.description = <<DESC
  Salt remote execution provider code sharable between Foreman and Foreman-Proxy
DESC

  s.files = Dir['lib/foreman_salt_core/**/*'] +
            ['lib/foreman_salt_core.rb', 'LICENSE']

  s.add_runtime_dependency('foreman-tasks-core', '>= 0.3.1')
end
