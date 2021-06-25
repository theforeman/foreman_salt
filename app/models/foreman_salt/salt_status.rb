module ForemanSalt
  # Define the class that holds different states a Salt host become
  class SaltStatus
    def self.minion_auth_waiting
      'Waiting for Salt Minion to authenticate'
    end

    def self.minion_auth_success
      'Salt Minion was authenticated successfully to Salt Master'
    end
  end
end
