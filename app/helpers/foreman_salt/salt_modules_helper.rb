module ForemanSalt
  module SaltModulesHelper
    def import_from_proxies
      links = SmartProxy.with_features('Salt').map do |proxy|
        display_link_if_authorized(_('Import from %s') % proxy.name, hash_for_import_salt_modules_path.merge(:proxy => proxy), :class => 'btn btn-default')
      end.flatten

      select_action_button(_('Import'), {}, links)
    end

    def salt_module_select(form, persisted)
      blank_opt = persisted ? {} : { :include_blank => true }
      select_items = persisted ? [form.object.salt_module] : SaltModule.order(:name)
      select_f form,
               :salt_module_id,
               select_items,
               :id,
               :to_label,
               blank_opt,
               :label => _('Salt State'),
               :disabled => persisted,
               :required => true
    end

    def colorize(state)
      # Make the state easier to read
      combo = %w(2E9DB9 4D1D59 2C777E 1C4758 591D4B)
      state.split('.').each_with_index.map do |section, index|
        "<span style='color: ##{combo[index % 5]}; font-weight: bold;'>#{section}</span>"
      end.join('.').html_safe
    end
  end
end
