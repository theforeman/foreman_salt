selector_text = "<%= select_f f, :salt_proxy_id, SmartProxy.unscoped.with_features('Salt').with_taxonomy_scope(@location,@organization, :path_ids), :id, :name,
                                 { :include_blank => blank_or_inherit_f(f, :salt_proxy) },
                                 { :label         => _('Salt Master') } %>"

Deface::Override.new(
  :virtual_path => 'hosts/_form',
  :name => 'add_salt_proxy_to_host',
  :insert_bottom => 'div#primary',
  :text => selector_text
)

Deface::Override.new(
  :virtual_path => 'hostgroups/_form',
  :name => 'add_salt_proxy_to_hostgroup',
  :insert_bottom => 'div#primary',
  :text => selector_text
)
