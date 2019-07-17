module ForemanSalt
  module StateImporter
    extend ActiveSupport::Concern

    private

    def find_proxy
      @proxy = SmartProxy.find(params[:proxy] || params[:smart_proxy_id])
      return :not_found unless @proxy
    end

    def fetch_states_from_proxy(proxy, environments = nil)
      result = { :changes => {},
                 :deletes => [] }

      new = ProxyAPI::Salt.new(:url => proxy.url).states_list
      old = SaltModule.to_hash

      environments ||= new.keys + old.keys

      environments.each do |environment|
        old_states = old[environment] || []
        new_states = new[environment] || []

        if old_states.any?
          removed = old_states - new_states
          added = new_states - old_states
        else
          added = new_states
          removed = []
        end

        if added.any? || removed.any?
          result[:changes][environment] = {}

          unless removed.blank?
            result[:changes][environment][:remove] = removed
            result[:deletes] << environment if removed.count == old[environment].count && added.blank?
          end

          result[:changes][environment][:add] = added unless added.blank?
        end
      end

      result
    end

    def add_to_environment(states, environment)
      environment = SaltEnvironment.where(:name => environment).first_or_create

      states.each do |state_name|
        state = SaltModule.where(:name => state_name).first_or_create
        state.salt_environments << environment unless state.salt_environments.include? environment
      end
    end

    def remove_from_environment(states, environment)
      return unless (environment = SaltEnvironment.friendly.find(environment))

      states.each do |state_name|
        state = SaltModule.friendly.find(state_name)
        state&.salt_environments&.delete(environment)
      end
    end

    def clean_orphans
      SaltModule.all.each do |state|
        state.destroy if state.salt_environments.empty?
      end

      SaltEnvironment.all.each do |environment|
        environment.destroy if environment.salt_modules.empty?
      end
    end
  end
end
