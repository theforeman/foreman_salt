module Actions
  module ForemanSalt
    class ReportImport < Actions::EntryAction
      def resource_locks
        :report_import
      end

      def plan(job, proxy_id)
        plan_self(:job_id => job[:job_id], :report => job[:result], :proxy_id => proxy_id)
      end

      def run
        ::User.as_anonymous_admin do
          reports = ::ForemanSalt::ReportImporter.import(input[:report], input[:proxy_id])

          output[:state] = { :message => "Imported #{reports.count} new reports" }
          output[:hosts] = reports.map { |report| report.host.name }
        end
      end

      def humanized_name
        _("Process Highstate Report: #{input[:job_id]}")
      end
    end
  end
end
