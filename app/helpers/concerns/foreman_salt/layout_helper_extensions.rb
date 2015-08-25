module ForemanSalt
  module LayoutHelperExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :authorized_associations_permission_name, :salt
    end

    # Foreman tries to magically guess permission names, but it doesn't work
    # with plugins. #11408 ForemanSalt models that require permissions provide
    # a self.permission_name method
    def authorized_associations_permission_name_with_salt(klass)
      if klass.respond_to?(:permission_name)
        klass.permission_name(:view)
      else
        authorized_associations_permission_name_without_salt(klass)
      end
    end
  end
end
