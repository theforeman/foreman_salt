# frozen_string_literal: true

Foreman::Plugin.register :foreman_salt do
  requires_foreman '>= 1.24'

  apipie_documented_controllers ["#{ForemanSalt::Engine.root}/app/controllers/foreman_salt/api/v2/*.rb"]

  # Menus
  divider :top_menu, parent: :configure_menu, caption: 'Salt'
  menu :top_menu, :salt_environments,
    url_hash: { controller: :'foreman_salt/salt_environments', action: :index },
    caption: 'Environments',
    parent: :configure_menu

  menu :top_menu, :salt_modules,
    url_hash: { controller: :'foreman_salt/salt_modules', action: :index },
    caption: 'States',
    parent: :configure_menu

  menu :top_menu, :salt_variables,
    url_hash: { controller: :'foreman_salt/salt_variables', action: :index },
    caption: N_('Variables'),
    parent: :configure_menu

  # Existing permissions
  p = Foreman::AccessControl.permission(:edit_hostgroups)
  p.actions << 'foreman_salt/api/v2/salt_hostgroups/update'
  p.actions << 'hostgroups/salt_environment_selected'

  p = Foreman::AccessControl.permission(:view_hostgroups)
  p.actions << 'foreman_salt/api/v2/salt_hostgroups/show'

  # New permissions
  security_block :foreman_salt do
    permission :auth_smart_proxies_salt_autosign,
      { 'foreman_salt/api/v2/salt_autosign': [:auth] },
      resource_type: 'SmartProxy'

    permission :destroy_smart_proxies_salt_autosign,
      { 'foreman_salt/salt_autosign': [:destroy],
        'foreman_salt/api/v2/salt_autosign': [:destroy] },
      resource_type: 'SmartProxy'

    permission :create_smart_proxies_salt_autosign,
      { 'foreman_salt/salt_autosign': %i[new create],
        'foreman_salt/api/v2/salt_autosign': [:create] },
      resource_type: 'SmartProxy'

    permission :view_smart_proxies_salt_autosign,
      { 'foreman_salt/salt_autosign': [:index],
        'foreman_salt/api/v2/salt_autosign': [:index] },
      resource_type: 'SmartProxy'

    permission :create_salt_environments,
      { 'foreman_salt/salt_environments': %i[new create],
        'foreman_salt/api/v2/salt_environments': [:create] },
      resource_type: 'ForemanSalt::SaltEnvironment'

    permission :view_salt_environments,
      { 'foreman_salt/salt_environments': %i[index show auto_complete_search],
        'foreman_salt/api/v2/salt_environments': %i[index show] },
      resource_type: 'ForemanSalt::SaltEnvironment'

    permission :edit_salt_environments,
      { 'foreman_salt/salt_environments': %i[update edit] },
      resource_type: 'ForemanSalt::SaltEnvironment'

    permission :destroy_salt_environments,
      { 'foreman_salt/salt_environments': [:destroy],
        'foreman_salt/api/v2/salt_environments': [:destroy] },
      resource_type: 'ForemanSalt::SaltEnvironment'

    permission :view_salt_variables,
      { 'foreman_salt/salt_variables': %i[index auto_complete_search],
        'foreman_salt/api/v2/salt_variables': %i[index show],
        'lookup_values': [:index] },
      resource_type: 'ForemanSalt::SaltVariable'

    permission :edit_salt_variables,
      { 'foreman_salt/salt_variables': %i[edit update],
        'foreman_salt/api/v2/salt_variables': [:update],
        'lookup_values': [:update] },
      resource_type: 'ForemanSalt::SaltVariable'

    permission :destroy_salt_variables,
      { 'foreman_salt/salt_variables': [:destroy],
        'foreman_salt/api/v2/salt_variables': [:destroy],
        'foreman_salt/api/v2/salt_override_values': [:destroy],
        'lookup_values': [:destroy] },
      resource_type: 'ForemanSalt::SaltVariable'

    permission :create_salt_variables,
      { 'foreman_salt/salt_variables': %i[new create],
        'foreman_salt/api/v2/salt_variables': [:create],
        'foreman_salt/api/v2/salt_override_values': [:create],
        'lookup_values': [:create] },
      resource_type: 'ForemanSalt::SaltVariable'

    permission :create_reports,
      { 'foreman_salt/api/v2/jobs': [:upload] },
      resource_type: 'Report'

    permission :saltrun_hosts,
      { 'foreman_salt/minions': [:run] },
      resource_type: 'Host'

    permission :edit_hosts,
      { 'foreman_salt/api/v2/salt_minions': [:update],
        'foreman_salt/minions': [:salt_environment_selected],
        hosts: %i[select_multiple_salt_master update_multiple_salt_master
                  select_multiple_salt_environment update_multiple_salt_environment] },
      resource_type: 'Host'

    permission :view_hosts,
      { 'foreman_salt/minions': [:node],
        'foreman_salt/api/v2/salt_minions': %i[index show] },
      resource_type: 'Host'

    permission :view_smart_proxies_salt_keys,
      { 'foreman_salt/salt_keys': [:index],
        'foreman_salt/api/v2/salt_keys': [:index] },
      resource_type: 'SmartProxy'

    permission :destroy_smart_proxies_salt_keys,
      { 'foreman_salt/salt_keys': [:destroy],
        'foreman_salt/api/v2/salt_keys': [:destroy] },
      resource_type: 'SmartProxy'

    permission :edit_smart_proxies_salt_keys,
      { 'foreman_salt/salt_keys': %i[accept reject],
        'foreman_salt/api/v2/salt_keys': [:update] },
      resource_type: 'SmartProxy'

    permission :create_salt_modules,
      { 'foreman_salt/salt_modules': %i[new create],
        'foreman_salt/api/v2/salt_states': [:create] },
      resource_type: 'ForemanSalt::SaltModule'

    permission :import_salt_modules,
      { 'foreman_salt/salt_modules': %i[import apply_changes],
        'foreman_salt/api/v2/salt_states': [:import] },
      resource_type: 'ForemanSalt::SaltModule'

    permission :view_salt_modules,
      { 'foreman_salt/salt_modules': %i[index show auto_complete_search],
        'foreman_salt/api/v2/salt_states': %i[index show] },
      resource_type: 'ForemanSalt::SaltModule'

    permission :edit_salt_modules,
      { 'foreman_salt/salt_modules': %i[update edit] },
      resource_type: 'ForemanSalt::SaltModule'

    permission :destroy_salt_modules,
      { 'foreman_salt/salt_modules': [:destroy],
        'foreman_salt/api/v2/salt_states': [:destroy] },
      resource_type: 'ForemanSalt::SaltModule'
  end

  # Roles
  role 'Salt admin', %i[saltrun_hosts
                        create_salt_modules view_salt_modules
                        edit_salt_modules destroy_salt_modules
                        import_salt_modules
                        view_smart_proxies_salt_keys
                        edit_smart_proxies_salt_keys destroy_smart_proxies_salt_keys
                        create_smart_proxies_salt_autosign view_smart_proxies_salt_autosign
                        destroy_smart_proxies_salt_autosign auth_smart_proxies_salt_autosign
                        create_salt_environments view_salt_environments
                        edit_salt_environments destroy_salt_environments
                        create_salt_variables view_salt_variables
                        edit_salt_variables destroy_salt_variables
                        view_hostgroups edit_hostgroups]

  role 'Salt viewer', %i[view_smart_proxies_salt_keys
                         view_smart_proxies_salt_autosign
                         view_salt_variables
                         view_salt_environments
                         view_salt_modules
                         view_hostgroups]

  # Parameter filters
  parameter_filter Hostgroup,
    :salt_proxy_id, :salt_proxy_name, :salt_environment_id,
    :salt_environment_name, salt_modules: [], salt_module_ids: []
  parameter_filter Host::Managed,
    :salt_proxy_id, :salt_proxy_name,
    :salt_environment_id, :salt_environment_name, salt_modules: [],
                                                  salt_module_ids: []
end
