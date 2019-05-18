if defined? ForemanRemoteExecution
  module ForemanSalt
    class SaltProvider < RemoteExecutionProvider
      class << self
        def supports_effective_user?
          true
        end

        def proxy_operation_name
          'salt'
        end

        def humanized_name
          'Salt'
        end

        def proxy_command_options(template_invocation, host)
          super(template_invocation, host)
            .merge({ :name => host.name })
        end

        def ssh_password(_host); end
        def ssh_key_passphrase(_host); end
        def sudo_password(_host); end
      end
    end
  end
end
