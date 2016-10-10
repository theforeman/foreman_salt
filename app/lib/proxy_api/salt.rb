module ::ProxyAPI
  class Salt < ::ProxyAPI::Resource
    def initialize(args)
      @url  = args[:url] + '/salt/'
      super args
    end

    def autosign_list
      parse(get('autosign'))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to fetch autosign list'))
    end

    def autosign_create(name)
      parse(post('', "autosign/#{URI.escape(name)}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to set Salt autosign for %s'), name)
    end

    def autosign_remove(name)
      parse(delete("autosign/#{URI.escape(name)}"))
    rescue RestClient::ResourceNotFound
      true # entry doesn't exists anyway
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to delete Salt autosign for %s'), name)
    end

    def environments_list
      parse(get('environments'))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to fetch Salt environments list'))
    end

    def states_list
      states = {}

      environments_list.each do |environment|
        states[environment] = parse(get("environments/#{environment}"))
      end

      states
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to fetch Salt states list'))
    end

    def key_list
      parse(get('key'))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to fetch Salt key list'))
    end

    def key_accept(name)
      parse(post('', "key/#{name}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to accept Salt key for %s'), name)
    end

    def key_reject(name)
      parse(delete("key/reject/#{name}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to reject Salt key for %s'), name)
    end

    def key_delete(name)
      parse(delete("key/#{name}"))
    rescue RestClient::ResourceNotFound
      true
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to delete Salt key for %s'), name)
    end

    def highstate(name, env, states)
      payload = {
        :saltenv => env,
        :states => states
      }
      parse(post(JSON.generate(payload), "highstate/#{name}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to run Salt state.highstate for %s'), name)
    end
  end
end
