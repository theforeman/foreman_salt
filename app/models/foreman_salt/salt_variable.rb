# frozen_string_literal: true

module ForemanSalt
  # Represents the variables used in Salt
  class SaltVariable < LookupKey
    belongs_to :salt_module, :inverse_of => :salt_variables
    validates :salt_module_id, :presence => true
    before_validation :cast_default_value, :if => :override?
    scoped_search :on => :key, :aliases => [:name], :complete_value => true
    scoped_search :relation => :salt_module, :on => :name,
                  :complete_value => true, :rename => :salt_module

    def salt?
      true
    end

    def self.humanize_class_name(options = nil)
      if options.present?
        super
      else
        "Salt variable"
      end
    end

    def editable_by_user?
      SaltVariable.authorized(:edit_external_parameters).where(:id => id).exists?
    end
  end
end
