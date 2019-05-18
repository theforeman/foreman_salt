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
      command = %w(salt cmd.run)
      command << @options['name']
      command << @options['script']
      command << "runas=#{@options['effective_user']}" if @options['effective_user']
      command
    end
  end
end
