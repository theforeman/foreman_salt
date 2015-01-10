module ForemanSalt
  module Concerns
    module Orchestration
      module Salt
        extend ActiveSupport::Concern
        include ::Orchestration

        included do
          after_validation :queue_salt_autosign
          before_destroy   :queue_salt_destroy
        end

        def salt?
          name.present? && salt_proxy.present?
        end

        def initialize_salt
          @salt_api ||= ProxyAPI::Salt.new :url => salt_proxy.url
        end

        def queue_salt_autosign
          return unless salt? && errors.empty?
          new_record? ? queue_set_salt_autosign : queue_update_salt_autosign
        end

        def queue_set_salt_autosign
          # do nothing - we'll set autosign at the last second: when a host requests a provision URL
        end

        def queue_update_salt_autosign
          # Host has been built --> remove auto sign
          if old.build? and !build?
            queue.create(:name => _('Remove autosign entry for %s') % self, :priority => 50, :action => [self, :del_salt_autosign])
          end
        end

        def queue_salt_destroy
          return unless salt? && errors.empty?
          queue.create(:name => _('Remove autosign entry for %s') % self, :priority => 50, :action => [self, :del_salt_autosign])
          queue.create(:name => _('Delete existing salt key for %s') % self, :priority => 50, :action => [self, :del_salt_key])
        end

        def queue_del_salt_autosign
          return unless salt? && errors.empty?
          queue.create(:name => _('Remove autosign entry for %s') % self, :priority => 50, :action => [self, :del_salt_autosign])
        end

        def set_salt_autosign
          logger.info "Create autosign entry for #{name}"
          initialize_salt
          del_salt_key # if there's already an existing key
          @salt_api.autosign_create name
        rescue => e
          failure _("Failed to create %{name}'s Salt autosign entry: %{e}") % { :name => name, :e => e }
        end

        def del_salt_autosign
          logger.info "Remove autosign entry for #{name}"
          initialize_salt
          @salt_api.autosign_remove name
        rescue => e
          failure _("Failed to remove %{name}'s Salt autosign entry: %{e}") % { :name => name, :e => e }
        end

        def del_salt_key
          logger.info "Delete salt key for #{name}"
          initialize_salt
          @salt_api.key_delete name
        rescue => e
          failure _("Failed to delete %{name}'s Salt key: %{e}") % { :name => name, :e => e }
        end
      end
    end
  end
end
