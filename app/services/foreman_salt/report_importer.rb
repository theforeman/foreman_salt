module ForemanSalt
  class ReportImporter
    delegate :logger, :to => :Rails
    attr_reader :report

    def self.import(raw, proxy_id = nil)
      raise ::Foreman::Exception.new(_('Invalid report')) unless raw.is_a?(Hash)
      raw.map do |host, report|
        importer = ForemanSalt::ReportImporter.new(host, report, proxy_id)
        importer.import
        importer.report
      end
    end

    def initialize(host, raw, proxy_id = nil)
      @host = find_or_create_host(host)
      @raw = raw
      @proxy_id = proxy_id
    end

    def import
      logger.info "processing report for #{@host}"
      logger.debug { "Report: #{@raw.inspect}" }

      if @host.new_record? && !Setting[:create_new_host_when_report_is_uploaded]
        logger.info("skipping report for #{@host} as its an unknown host and create_new_host_when_report_is_uploaded setting is disabled")
        return Report.new
      end

      @host.salt_proxy_id ||= @proxy_id
      @host.last_report = start_time

      if @raw.is_a? Array
        process_failures # If Salt sends us only an array, it's a list of fatal failures
      else
        process_normal
      end

      @host.save(:validate => false)
      logger.info("Imported report for #{@host} in #{(Time.now - start_time).round(2)} seconds")
    end

    private

    def find_or_create_host(host)
      @host ||= Host::Base.find_by_name(host)

      unless @host
        new = Host::Managed.new(:name => host)
        new.save(:validate => false)
        @host = new
      end

      @host
    end

    def import_log_messages
      @raw.each do |resource, result|
        level = if result['changes'].blank? && result['result']
          :info
        elsif result['result'] == false
          :err
        else
          :notice
        end

        source = Source.find_or_create(resource)

        message = if result['changes']['diff']
          result['changes']['diff']
        elsif !result['comment'].blank?
          result['comment']
        else
          'No message available'
        end

        message = Message.find_or_create(message)
        Log.create(:message_id => message.id, :source_id => source.id, :report => @report, :level => level)
      end
    end

    def calculate_metrics
      success = 0
      failed = 0
      changed = 0
      restarted = 0
      restarted_failed = 0

      time = {}

      @raw.each do |resource, result|
        next unless result.is_a? Hash

        if result['result'] == true
          success += 1
          if resource.match(/^service_/) && result['comment'].include?('restarted')
            restarted += 1
          elsif !result['changes'].blank?
            changed += 1
          end
        elsif result['result'] == false
          if resource.match(/^service_/) && result['comment'].include?('restarted')
            restarted_failed += 1
          else
            failed += 1
          end
        end

        time[resource] = result['duration'] if result['duration']
      end

      time[:total] = time.values.inject(&:+)
      events = {:total => changed + failed + restarted + restarted_failed, :success => success + restarted, :failure => failed + restarted_failed}

      changes = {:total => changed + restarted}

      resources = {'total' => @raw.size, 'applied' => changed, 'restarted' => restarted, 'failed' => failed,
        'failed_restarts' => restarted_failed, 'skipped' => 0, 'scheduled' => 0}

      {:events => events, :resources => resources, :changes => changes, :time => time}
    end

    def process_normal
        metrics = calculate_metrics
        status = ReportStatusCalculator.new(:counters => metrics[:resources].slice(*::Report::METRIC)).calculate

        @host.puppet_status = status

        @report = Report.new(:host => @host, :reported_at => start_time, :status => status, :metrics => metrics)
        return @report unless @report.save
        import_log_messages
    end


    def process_failures
      status = ReportStatusCalculator.new({:counters => {'failed' => @raw.size}}).calculate
      @report = Report.create(:host => @host, :reported_at => Time.now, :status => status, :metrics => {})

      @host.puppet_status = status

      source = Source.find_or_create('Salt')
      @raw.each do |failure|
        message = Message.find_or_create(failure)
        Log.create(:message_id => message.id, :source_id => source.id, :report => @report, :level => :err)
      end
    end

    def start_time
      @start_time ||= Time.now
    end
  end
end
