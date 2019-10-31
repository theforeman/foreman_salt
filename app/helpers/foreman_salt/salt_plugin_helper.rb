# frozen_string_literal: true

require "#{ForemanSalt::Engine.root}/lib/foreman_salt/version"

module ForemanSalt
  # General helper functions for foreman_salt
  module SaltPluginHelper
    def salt_doc_url
      major_version = ::ForemanSalt::VERSION.split('.')[0]
      "https://theforeman.org/plugins/foreman_salt/#{major_version}.x/index.html"
    end
  end
end
