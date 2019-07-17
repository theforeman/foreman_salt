require 'test_plugin_helper'
require 'integration_test_helper'

module ForemanSalt
  class HostJSTest < IntegrationTestWithJavascript
    def index_modal
      page.find('#confirmation-modal')
    end

    def multiple_actions_div
      page.find('#submit_multiple')
    end

    setup do
      as_admin do
        proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
        salt_environment = FactoryBot.create(:salt_environment)
        @host = FactoryBot.create(:host, :salt_proxy => proxy, :salt_environment => salt_environment)
        Setting::Salt.load_defaults
      end
    end

    describe "hosts details run salt button" do
      test "verify run salt button availabilty" do
        Setting[:salt_hide_run_salt_button] = false
        visit hosts_path
        click_link @host.fqdn
        assert page.has_link?("Run Salt")
      end

      test "verify run salt button absence" do
        Setting[:salt_hide_run_salt_button] = true
        visit hosts_path
        click_link @host.fqdn
        assert_not page.has_link?("Run Salt")
      end
    end

    describe "hosts index salt multiple actions" do
      test 'change salt master action' do
        visit hosts_path
        check 'check_all'

        # Ensure and wait for all hosts to be checked, and that no unchecked hosts remain
        assert page.has_no_selector?('input.host_select_boxes:not(:checked)')

        # Dropdown visible?
        assert multiple_actions_div.find('.dropdown-toggle').visible?
        multiple_actions_div.find('.dropdown-toggle').click
        assert multiple_actions_div.find('ul').visible?

        # Hosts are added to cookie
        host_ids_on_cookie = JSON.parse(CGI.unescape(get_me_the_cookie('_ForemanSelectedhosts')&.fetch(:value)))
        assert(host_ids_on_cookie.include?(@host.id))

        within('#submit_multiple') do
          click_on('Change Salt Master')
        end

        assert index_modal.visible?, "Modal window was shown"
        page.find('#proxy_proxy_id').find("option[value='#{@host.salt_proxy.id}']").select_option

        # remove hosts cookie on submit
        index_modal.find('.btn-primary').click
        assert_current_path hosts_path
        assert_empty(get_me_the_cookie('_ForemanSelectedhosts'))
      end

      test 'change salt environment action' do
        visit hosts_path
        check 'check_all'

        # Ensure and wait for all hosts to be checked, and that no unchecked hosts remain
        assert page.has_no_selector?('input.host_select_boxes:not(:checked)')

        # Dropdown visible?
        assert multiple_actions_div.find('.dropdown-toggle').visible?
        multiple_actions_div.find('.dropdown-toggle').click
        assert multiple_actions_div.find('ul').visible?

        # Hosts are added to cookie
        host_ids_on_cookie = JSON.parse(CGI.unescape(get_me_the_cookie('_ForemanSelectedhosts')&.fetch(:value)))
        assert(host_ids_on_cookie.include?(@host.id))

        within('#submit_multiple') do
          click_on('Change Salt Environment')
        end

        assert index_modal.visible?, "Modal window was shown"
        page.find('#salt_environment_id').find("option[value='#{@host.salt_environment.id}']").select_option

        # remove hosts cookie on submit
        index_modal.find('.btn-primary').click
        assert_current_path hosts_path
        assert_empty(get_me_the_cookie('_ForemanSelectedhosts'))
      end
    end
  end
end
