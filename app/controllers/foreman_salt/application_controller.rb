module ForemanSalt
  class ApplicationController < ::ApplicationController

    def resource_class
      "ForemanSalt::#{controller_name.singularize.classify}".constantize
    end
  end
end
