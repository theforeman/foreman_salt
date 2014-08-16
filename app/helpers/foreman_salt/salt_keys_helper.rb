module ForemanSalt
  module SaltKeysHelper
    def salt_keys_state_filter
      select_tag "Filter", options_for_select(["", _("Accepted"),_("Rejected"), _("Unaccepted")], params[:state]),
        :onchange => "window.location.href = location.protocol + '//' + location.host + location.pathname + (this.value == '' ? '' : ('?state=' + this.value))"
    end
  end
end

