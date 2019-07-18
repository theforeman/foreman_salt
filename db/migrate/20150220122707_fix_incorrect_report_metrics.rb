class FixIncorrectReportMetrics < ActiveRecord::Migration[4.2]
  def up
    Report.all.each do |report|
      next unless report.metrics && report.metrics['time']

      metrics = report.metrics.dup

      report.metrics['time'].each do |resource, time|
        metrics['time'][resource] = if time.is_a? String
                                      Float(time.delete(' ms')) rescue nil
                                    else
                                      time
                                    end
      end

      report.update_attributes(:metrics => metrics) if metrics != report.metrics
    end
  end

  def down
    # Nothing
  end
end
