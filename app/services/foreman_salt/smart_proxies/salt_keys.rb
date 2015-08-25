module ForemanSalt
  class SmartProxies::SaltKeys
    attr_reader :name, :state, :fingerprint, :smart_proxy_id

    def initialize(opts)
      @name, @state, @fingerprint, @smart_proxy_id = opts.flatten
    end

    class << self
      def all(proxy)
        fail ::Foreman::Exception.new(N_('Must specify a Smart Proxy to use')) if proxy.nil?

        unless (keys = Rails.cache.read("saltkeys_#{proxy.id}"))
          api = ProxyAPI::Salt.new(:url => proxy.url)
          keys = api.key_list.map do |name, properties|
            new([name.strip, properties['state'], properties['fingerprint'], proxy.id])
          end.compact

          Rails.cache.write("saltkeys_#{proxy.id}", keys, :expires_in => 1.minute) if Rails.env.production?
        end
        keys
      end

      def find(proxy, name)
        all(proxy).find { |c| c.name == name }
      end

      def find_by_state(proxy, state)
        all(proxy).select { |c| c.state == state }
      end
    end

    def accept
      fail ::Foreman::Exception.new(N_('unable to re-accept an accepted key')) unless state == 'unaccepted'
      proxy = SmartProxy.find(smart_proxy_id)
      Rails.cache.delete("saltkeys_#{proxy.id}") if Rails.env.production?
      ProxyAPI::Salt.new(:url => proxy.url).key_accept name
    end

    def reject
      fail ::Foreman::Exception.new(N_('unable to reject an accepted key')) unless state == 'unaccepted'
      proxy = SmartProxy.find(smart_proxy_id)
      Rails.cache.delete("saltkeys_#{proxy.id}") if Rails.env.production?
      ProxyAPI::Salt.new(:url => proxy.url).key_reject name
    end

    def delete
      proxy = SmartProxy.find(smart_proxy_id)
      Rails.cache.delete("saltkeys_#{proxy.id}") if Rails.env.production?
      ProxyAPI::Salt.new(:url => proxy.url).key_delete name
    end

    def to_param
      name
    end

    def to_s
      name
    end

    def <=>(other)
      name <=> other.name
    end
  end
end
