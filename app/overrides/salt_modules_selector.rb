Deface::Override.new(:virtual_path => "hosts/_form",
  :name => "add_salt_modules_tab",
  :insert_after => 'li.active',
  :partial => '../overrides/foreman/salt_modules/host_tab')

Deface::Override.new(:virtual_path => "hosts/_form",
  :name => "add_salt_modules_tab_pane",
  :insert_before => 'div#puppet_klasses',
  :partial => '../overrides/foreman/salt_modules/host_tab_pane')
