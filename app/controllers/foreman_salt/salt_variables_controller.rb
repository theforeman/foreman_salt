# frozen_string_literal: true

module ForemanSalt
  # UI controller for salt variables
  class SaltVariablesController < ::LookupKeysController
    include Foreman::Controller::AutoCompleteSearch
    include ::ForemanSalt::Concerns::SaltVariableParameters

    before_action :find_resource, :only => [:edit, :update, :destroy], :if => proc { params[:id] }

    def index
      @salt_variables = resource_base.search_for(params[:search],
                                                 :order => params[:order]).paginate(:page => params[:page],
                                                 :per_page => params[:per_page])
    end

    def new
      @salt_variable = SaltVariable.new
    end

    def create
      @salt_variable = SaltVariable.new(salt_variable_params)
      if @salt_variable.save
        process_success
      else
        process_error
      end
    end

    def resource_class
      "ForemanSalt::#{controller_name.singularize.classify}".constantize
    end

    private

    def default_order; end

    def resource
      @salt_variable
    end

    def resource_params
      salt_variable_params
    end
  end
end
