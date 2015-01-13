require 'uri'

module ForemanSalt
  module Api
    module V2
      class JobsController < ::Api::V2::BaseController
        include ::Api::Version2
        include ::Foreman::Controller::SmartProxyAuth

        add_smart_proxy_filters :upload, :features => 'Salt'

        resource_description do
          api_base_url '/salt/api'
        end

        def_param_group :job do
          param :job, Hash, :required => true, :action_aware => true do
            param :job_id, Integer, :required => true, :desc => N_('JID')
            param :function, String, :required => true, :desc => N_('Function')
            param :result, Hash, :required => true, :desc => N_('Result')
          end
        end

        api :POST, '/upload/', N_('Upload a Job')
        param_group :job, :as => :upload

        def upload
          Rails.logger.info("Processing job #{params[:job][:job_id]} from Salt.")
          case params[:job][:function]
          when 'state.highstate'
            # Dynflowize the action if we can, otherwise we'll do it live
            if defined? ForemanTasks
              task = ForemanTasks.async_task(::Actions::ForemanSalt::ReportImport, params[:job], detected_proxy.try(:id))
              render :json => {:task_id => task.id}
            else
              reports = ForemanSalt::ReportImporter.import(params[:job][:result], detected_proxy.try(:id))
              render :json => {:message => "Imported #{reports.count} new reports."}
            end
          else
            render :json => {:message => 'Unsupported function'}, :status => :unprocessable_entity
          end
        rescue ::Foreman::Exception => e
          render :json => {:message => e.to_s}, :status => :unprocessable_entity
        end

        def resource_class
          ::Report
        end

        private

        def action_permission
          case params[:action]
            when 'upload'
              :create
          else
            super
          end
        end
      end
    end
  end
end

