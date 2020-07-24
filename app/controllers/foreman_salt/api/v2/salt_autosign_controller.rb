require 'ostruct'

module ForemanSalt
  module Api
    module V2
      class SaltAutosignController < ::ForemanSalt::Api::V2::BaseController
        include ::Foreman::Controller::SmartProxyAuth
        include ::Foreman::Controller::Parameters::Host

        # The add_smart_proxy_filters must be executed first! Otherwise, resource_finder won't work properly
        add_smart_proxy_filters :auth

        before_action :find_proxy, except: [:auth]
        before_action :find_host, :find_proxy_via_host, only: [:auth]
        before_action :setup_proxy

        api :GET, '/salt_autosign/:smart_proxy_id', N_('List all autosign records')
        param :smart_proxy_id, :identifier_dottable, :required => true
        def index
          @salt_autosigns = all_autosign
        end

        api :POST, '/salt_autosign/:smart_proxy_id', N_('Create an autosign record')
        param :smart_proxy_id, :identifier_dottable, :required => true
        param :record, String, :required => true, :desc => N_('Autosign record')
        def create
          @api.autosign_create params[:record]
          @salt_autosign = { :record => params[:record] }
        end

        api :DELETE, '/salt_autosign/:smart_proxy_id/:record', N_('Delete an autosign record')
        param :smart_proxy_id, :identifier_dottable, :required => true
        param :record, String, :required => true, :desc => N_('Autosign record')
        def destroy
          @api.autosign_remove params[:record]
          render :json => { root_node_name => _('Record deleted.') }
        end

        api :PUT, '/salt_autosign_auth', N_("Set the salt_status as \'successful authentication\' and remove the corresponding autosign key from the Smart Proxy")
        param :name, String, :required => true
        def auth
          Rails.logger.info("Removing Salt autosign key and update status for host #{@host}")
          @api.autosign_remove_key(@host.salt_autosign_key) unless @host.salt_autosign_key.nil?
          @host.update(:salt_status => ForemanSalt::SaltStatus.minion_auth_success)
          render :json => { :message => "Removed autosign key and updated status succesfully" }, :status => 204
        rescue ::Foreman::Exception => e
          Rails.logger.warn("Cannot delete autosign key of host (id => #{params[:name]}) state: #{e}")
          render :json => { :message => e.to_s }, :status => :unprocessable_entity
        end

        def metadata_total
          @total ||= all_autosign.count
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

        def all_autosign
          @_autosigns ||= @api.autosign_list.map { |record| OpenStruct.new(:record => record) }
        end

        def find_host
          @host = resource_finder(Host.authorized(:view_hosts), params[:name])
          not_found unless @host
        end

        def find_proxy
          @proxy = ::SmartProxy.friendly.find(params[:smart_proxy_id])
          not_found unless @proxy
        end

        def find_proxy_via_host
          @proxy = ::SmartProxy.friendly.find(@host.salt_proxy.id)
          not_found unless @proxy
        end

        def setup_proxy
          @api = ProxyAPI::Salt.new(:url => @proxy.url)
        end
      end
    end
  end
end
