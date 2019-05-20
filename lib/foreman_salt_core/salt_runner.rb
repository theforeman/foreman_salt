module ForemanSaltCore
  class SaltRunner < ForemanTasksCore::Runner::CommandRunner
    DEFAULT_REFRESH_INTERVAL = 1

    def initialize(options, suspended_action:)
      super(options, :suspended_action => suspended_action)
      @options = options
    end

    def start
      command = generate_command
      logger.debug("Running command '#{command.join(' ')}'")
      initialize_command(*command)
    end

    def kill
      publish_data('== TASK ABORTED BY USER ==', 'stdout')
      publish_exit_status(1)
      ::Process.kill('SIGTERM', @command_pid)
    end

    private

    def generate_command
      command = %w(salt)
      command << @options['name']
      command << 'state.template_str'
      command << @options['script']
      command
    end
  end
end
