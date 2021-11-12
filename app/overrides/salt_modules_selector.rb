Deface::Override.new(virtual_path: 'hosts/_form',
                     name: 'add_salt_modules_tab_to_host',
                     insert_after: 'li.active',
                     partial: 'foreman_salt/salt_modules/host_tab')

Deface::Override.new(virtual_path: 'hosts/_form',
                     name: 'add_salt_modules_tab_pane_to_host',
                     insert_before: 'div#primary',
                     partial: 'foreman_salt/salt_modules/host_tab_pane')

Deface::Override.new(virtual_path: 'hostgroups/_form',
                     name: 'add_salt_modules_tab_to_hg',
                     insert_after: 'li.active',
                     partial: 'foreman_salt/salt_modules/host_tab')

Deface::Override.new(virtual_path: 'hostgroups/_form',
                     name: 'add_salt_modules_tab_pane_to_hg',
                     insert_before: 'div#primary',
                     partial: 'foreman_salt/salt_modules/host_tab_pane')
