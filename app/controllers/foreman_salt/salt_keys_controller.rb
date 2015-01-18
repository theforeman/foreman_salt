module ForemanSalt
  class SaltKeysController < ::ForemanSalt::ApplicationController
    def index
      @proxy = find_proxy

      Rails.cache.delete("saltkeys_#{@proxy.id}") if params[:expire_cache] == 'true'
      keys = if params[:state].blank?
               SmartProxies::SaltKeys.all @proxy
             else
               SmartProxies::SaltKeys.find_by_state @proxy, params[:state].downcase
             end
      @keys = keys.sort.paginate :page => params[:page], :per_page => Setting::General.entries_per_page
    end

    def accept
      @proxy = find_proxy(:edit_smart_proxies_salt_keys)
      key = SmartProxies::SaltKeys.find(@proxy, params[:salt_key_id])
      if key.accept
        process_success(:success_redirect => hash_for_smart_proxy_salt_keys_path(:state => params[:state], :expire_cache => true),
                         :success_msg => _("Key accepted for #{key}"), :object_name => key.to_s)
      else
        process_error(:redirect => hash_for_smart_proxy_salt_keys_path(:state => params[:state], :expire_cache => true))
      end
    end

    def reject
      @proxy = find_proxy(:edit_smart_proxies_salt_keys)
      key = SmartProxies::SaltKeys.find(@proxy, params[:salt_key_id])
      if key.reject
        process_success(:success_redirect => hash_for_smart_proxy_salt_keys_path(:state => params[:state], :expire_cache => true),
                         :success_msg => _("Key rejected for #{key}"), :object_name => key.to_s)
      else
        process_error(:redirect => hash_for_smart_proxy_salt_keys_path(:state => params[:state], :expire_cache => true))
      end
    end

    def destroy
      @proxy = find_proxy(:destroy_smart_proxies_salt_keys)
      key = SmartProxies::SaltKeys.find(@proxy, params[:id])
      if key.delete
        process_success(:success_redirect => hash_for_smart_proxy_salt_keys_path(:state => params[:state], :expire_cache => true),
                         :success_msg => _("Key deleted for #{key}"), :object_name => key.to_s)
      else
        process_error(:redirect => hash_for_smart_proxy_salt_keys_path(:state => params[:state], :expire_cache => true))
      end
    end

    private

    def controller_permission
      'smart_proxies_salt_keys'
    end

    def find_proxy(permission = :view_smart_proxies_salt_keys)
      SmartProxy.authorized(permission).find(params[:smart_proxy_id])
    end
  end
end
