module ForemanSalt
  module Api
    module V2
      class SaltKeysController < ::ForemanSalt::Api::V2::BaseController
        before_filter :find_proxy
        before_filter :find_key, :only => [:update, :destroy]

        api :GET, '/salt_keys/:smart_proxy_id', N_('List all Salt keys')
        param :smart_proxy_id, :identifier_dottable, :required => true
        def index
          @salt_keys = all_keys
        end

        def_param_group :key do
          param :smart_proxy_id, :identifier_dottable, :required => true
          param :name, String, :required => true, :desc => N_('FQDN of host that key belongs to')
        end

        api :PUT, '/salt_keys/:smart_proxy_id/:name', N_('Update a Salt Key')
        param :name, :identifier_dottable, :required => true
        param :smart_proxy_id, :identifier_dottable, :required => true
        param :state, String, :required => true, :desc => N_('State can be "accepted" or "rejected"')
        def update
          case params[:key][:state]
          when 'accepted'
            @key.accept
          when 'rejected'
            @key.reject
          end

          @salt_key = find_key(@key.name)
        end

        api :DELETE, '/salt_keys/:smart_proxy_id/:name', N_('Delete a Salt Key')
        param_group :key, :as => :destroy
        def destroy
          if @key.delete
            message = 'Key successfully deleted.'
          else
            message = 'Unable to delete key.'
          end
          render :json => { root_node_name => message }
        end

        def metadata_total
          @total ||= all_keys.count
        end

        def metadata_subtotal
          metadata_total
        end

        def metadata_page
          1
        end

        def metadata_per_page
          metadata_total
        end

        private

        def all_keys
          @_keys ||= SmartProxies::SaltKeys.all(@proxy)
        end

        def find_proxy
          @proxy = ::SmartProxy.find(params[:smart_proxy_id])
          not_found unless @proxy
        end

        def find_key(name = params[:name])
          @key = SmartProxies::SaltKeys.find(@proxy, name)
          @key || not_found
        end
      end
    end
  end
end
