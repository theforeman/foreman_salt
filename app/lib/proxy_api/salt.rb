module ::ProxyAPI
  class Salt < ::ProxyAPI::Resource
    def initialize args
      @url  = args[:url] + "/salt/"
      super args
    end

    def autosign_create name
      parse(post("", "autosign/#{name}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to set Salt autosign for %s"), name)
    end

    def autosign_remove name
      parse(delete("autosign/#{name}"))
    rescue RestClient::ResourceNotFound
      true # entry doesn't exists anyway
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete Salt autosign for %s"), name)
    end

    def highstate name
      parse(get("highstate/#{name}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to run Salt state.highstate for %s"), name)
    end
  end
end
