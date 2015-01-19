require 'ostruct'

module ForemanSalt
  module Api
    module V2
      class SaltAutosignController < ::ForemanSalt::Api::V2::BaseController
        before_filter :find_proxy, :setup_proxy

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

        def find_proxy
          @proxy = ::SmartProxy.find(params[:smart_proxy_id])
          not_found unless @proxy
        end

        def setup_proxy
          @api = ProxyAPI::Salt.new(:url => @proxy.url)
        end
      end
    end
  end
end
