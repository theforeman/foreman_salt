module ForemanSalt
  class SaltAutosignController < ::ForemanSalt::ApplicationController
    def index
      setup
      autosign = @api.autosign_list
      @autosign = autosign.paginate :page => params[:page], :per_page => Setting::General.entries_per_page
    end

    def new
      setup
    end

    def create
      setup

      if @api.autosign_create(params[:id])
        process_success(:success_redirect => hash_for_smart_proxy_salt_autosign_index_path, :success_msg => _("Autosign created for #{params[:id]}"),
                        :object_name => params[:id])
      else
        process_error(:redirect => hash_for_smart_proxy_salt_autosign_index_path)
      end
    end

    def destroy
      setup

      if @api.autosign_remove(params[:id])
        process_success(:success_redirect => hash_for_smart_proxy_salt_autosign_index_path, :success_msg => _("Autosign deleted for #{params[:id]}"),
                        :object_name => params[:id])
      else
        process_error(:redirect => hash_for_smart_proxy_salt_autosign_index_path)
      end
    end

    private

    def setup
      @proxy = SmartProxy.authorized(:view_smart_proxies_salt_autosign).find(params[:smart_proxy_id])
      @api = ProxyAPI::Salt.new(:url => @proxy.url)
    end
  end
end
