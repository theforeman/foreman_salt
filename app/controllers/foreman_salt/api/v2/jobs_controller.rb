require 'uri'

module ForemanSalt
  module Api
    module V2
      class JobsController < ::ForemanSalt::Api::V2::BaseController
        include ::Foreman::Controller::SmartProxyAuth
        add_smart_proxy_filters :upload, :features => 'Salt'

        def_param_group :job do
          param :job, Hash, :required => true, :action_aware => true do
            param :job_id, Integer, :required => true, :desc => N_('JID')
            param :function, String, :required => true, :desc => N_('Function')
            param :result, Hash, :required => true, :desc => N_('Result')
          end
        end

        api :POST, '/upload', N_('Upload a Job')
        param_group :job, :as => :upload

        def upload
          Rails.logger.info("Processing job #{params[:job][:job_id]} from Salt.")
          case params[:job][:function]
          when 'state.highstate'
            task = ForemanTasks.async_task(::Actions::ForemanSalt::ReportImport, params[:job], detected_proxy.try(:id))
            render :json => { :task_id => task.id }
          else
            render :json => { :message => 'Unsupported function' }, :status => :unprocessable_entity
          end
        rescue ::Foreman::Exception => e
          render :json => { :message => e.to_s }, :status => :unprocessable_entity
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
