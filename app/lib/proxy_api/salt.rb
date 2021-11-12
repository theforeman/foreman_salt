module ::ProxyAPI
  class Salt < ::ProxyAPI::Resource
    def initialize(args)
      @url = "#{args[:url]}/salt/"
      super args
    end

    def autosign_list
      parse(get('autosign'))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to fetch autosign list'))
    end

    def autosign_create(name)
      parse(post('', "autosign/#{CGI.escape(name)}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to set Salt autosign hostname for %s'), name)
    end

    def autosign_remove(name)
      parse(delete("autosign/#{CGI.escape(name)}"))
    rescue RestClient::ResourceNotFound
      true # entry doesn't exists anyway
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to delete Salt autosign hostname for %s'), name)
    end

    def autosign_create_key(key)
      parse(post('', "autosign_key/#{CGI.escape(key)}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to create Salt autosign key %s'), key)
    end

    def autosign_remove_key(key)
      parse(delete("autosign_key/#{CGI.escape(key)}"))
    rescue RestClient::ResourceNotFound
      true # entry doesn't exists anyway
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to delete Salt autosign key %s'), key)
    end

    def environments_list
      parse(get('environments'))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to fetch Salt environments list'))
    end

    def states_list
      states = {}

      environments_list.each do |environment|
        states[environment] = parse(get("environments/#{environment}"))
      end

      states
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to fetch Salt states list'))
    end

    def key_list
      parse(get('key'))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to fetch Salt key list'))
    end

    def key_accept(name)
      parse(post('', "key/#{name}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to accept Salt key for %s'), name)
    end

    def key_reject(name)
      parse(delete("key/reject/#{name}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to reject Salt key for %s'), name)
    end

    def key_delete(name)
      parse(delete("key/#{name}"))
    rescue RestClient::ResourceNotFound
      true
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to delete Salt key for %s'), name)
    end

    def highstate(name)
      parse(post('', "highstate/#{name}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to run Salt state.highstate for %s'), name)
    end
  end
end
