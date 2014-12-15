module ForemanSalt
  module Concerns
    module HostgroupExtensions
      extend ActiveSupport::Concern

      included do
        has_and_belongs_to_many :salt_modules, :class_name => 'ForemanSalt::SaltModule'
        belongs_to :salt_proxy, :class_name => 'SmartProxy'
        belongs_to :salt_environment, :class_name => 'ForemanSalt::SaltEnvironment'
      end

      def salt_modules
        return super unless ancestry.present?
        ([super] + [inherited_salt_modules]).flatten.uniq.compact
      end

      def salt_module_ids
        return super unless ancestry.present?
        ([super] + [inherited_salt_module_ids]).flatten.uniq.compact
      end

      def inherited_salt_modules
        ForemanSalt::SaltModule.where(:id => inherited_salt_module_ids)
      end

      def inherited_salt_module_ids
        if ancestry.present?
          self.class.sort_by_ancestry(ancestors.reject { |ancestor| ancestor.salt_module_ids.empty? }).last.try(:salt_modules)
        else
          []
        end
      end

      def salt_proxy
        return super unless ancestry.present?
        SmartProxy.find_by_id(inherited_salt_proxy_id)
      end

      def inherited_salt_proxy_id
        if ancestry.present?
          read_attribute(:salt_proxy_id) || self.class.sort_by_ancestry(ancestors.where('salt_proxy_id is not NULL')).last.try(:salt_proxy_id)
        else
          self.salt_proxy_id
        end
      end

      def salt_environment
        return super unless ancestry.present?
        ForemanSalt::SaltEnvironment.find_by_id(inherited_salt_environment_id)
      end

      def inherited_salt_environment_id
        if ancestry.present?
          read_attribute(:salt_environment_id) || self.class.sort_by_ancestry(ancestors.where('salt_environment_id is not NULL')).last.try(:salt_environment_id)
        else
          self.salt_environment_id
        end
      end

      def salt_master
        salt_proxy.to_s
      end
    end
  end
end
