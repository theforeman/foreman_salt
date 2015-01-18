module ForemanSalt
  module Api
    module V2
      class BaseController < ::Api::V2::BaseController
        resource_description do
          resource_id 'foreman_salt'
          api_version 'v2'
          api_base_url '/salt/api'
        end
      end
    end
  end
end
