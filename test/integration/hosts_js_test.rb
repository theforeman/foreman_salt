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
      end
    end

    describe "hosts index salt multiple actions" do
      test 'change salt master action' do
        visit hosts_path
        page.find('#check_all').trigger('click')

        # Ensure and wait for all hosts to be checked, and that no unchecked hosts remain
        assert page.has_no_selector?('input.host_select_boxes:not(:checked)')

        # Dropdown visible?
        assert multiple_actions_div.find('.dropdown-toggle').visible?
        multiple_actions_div.find('.dropdown-toggle').click
        assert multiple_actions_div.find('ul').visible?

        # Hosts are added to cookie
        host_ids_on_cookie = JSON.parse(CGI.unescape(page.driver.cookies['_ForemanSelectedhosts'].value))
        assert(host_ids_on_cookie.include?(@host.id))

        within('#submit_multiple') do
          click_on('Change Salt Master')
        end

        assert index_modal.visible?, "Modal window was shown"
        page.find('#proxy_proxy_id').find("option[value='#{@host.salt_proxy.id}']").select_option

        # remove hosts cookie on submit
        index_modal.find('.btn-primary').click
        assert_current_path hosts_path
        assert_empty(page.driver.cookies['_ForemanSelectedhosts'])
      end

      test 'change salt environment action' do
        visit hosts_path
        page.find('#check_all').trigger('click')

        # Ensure and wait for all hosts to be checked, and that no unchecked hosts remain
        assert page.has_no_selector?('input.host_select_boxes:not(:checked)')

        # Dropdown visible?
        assert multiple_actions_div.find('.dropdown-toggle').visible?
        multiple_actions_div.find('.dropdown-toggle').click
        assert multiple_actions_div.find('ul').visible?

        # Hosts are added to cookie
        host_ids_on_cookie = JSON.parse(CGI.unescape(page.driver.cookies['_ForemanSelectedhosts'].value))
        assert(host_ids_on_cookie.include?(@host.id))

        within('#submit_multiple') do
          click_on('Change Salt Environment')
        end

        assert index_modal.visible?, "Modal window was shown"
        page.find('#salt_environment_id').find("option[value='#{@host.salt_environment.id}']").select_option

        # remove hosts cookie on submit
        index_modal.find('.btn-primary').click
        assert_current_path hosts_path
        assert_empty(page.driver.cookies['_ForemanSelectedhosts'])
      end
    end
  end
end
