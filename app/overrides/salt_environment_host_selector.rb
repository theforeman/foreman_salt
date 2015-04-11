selector_text = "<%= select_f f, :salt_environment_id, ForemanSalt::SaltEnvironment.all, :id, :name,
                                 { :include_blank => blank_or_inherit_f(f, :salt_environment) },
                                 { :label => _('Salt Environment'), :onchange => 'update_salt_states(this)', :'data-url' => salt_environment_selected_minions_path,
                                   :'data-host-id' => (@host || @hostgroup).id, :help_inline => :indicator} %>"

Deface::Override.new(:virtual_path  => 'hosts/_form',
                     :name          => 'add_salt_environment_to_host',
                     :insert_bottom => 'div#primary',
                     :text          =>  selector_text)
