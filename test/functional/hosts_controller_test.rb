require 'test_plugin_helper'

module ForemanSalt
  class HostsControllerExtensionsTest < ActionController::TestCase
    tests ::HostsController

    describe "setting salt master proxy on multiple hosts" do
      before do
        setup_user "edit"
        as_admin do
          @hosts = FactoryBot.create_list(:host, 2)
          @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
        end
      end

      test 'user without edit permission should not be able to change salt master' do
        @request.env['HTTP_REFERER'] = hosts_path

        params = { :host_ids => @hosts.map(&:id),
                   :proxy => { :proxy_id => '' } }

        post :update_multiple_salt_master, params: params,
          session: set_session_user.merge(:user => users(:one).id)
        assert_response :forbidden
      end

      test "should change the salt master proxy" do
        @request.env['HTTP_REFERER'] = hosts_path

        params = { :host_ids => @hosts.map(&:id),
                   :proxy => { :proxy_id => @proxy.id } }

        post :update_multiple_salt_master, params: params,
        session: set_session_user.merge(:user => users(:admin).id)

        assert_empty flash[:error]

        @hosts.each do |host|
          as_admin do
            assert_equal @proxy, host.reload.salt_proxy
          end
        end
      end

      test "should clear the salt master proxy of multiple hosts" do
        @request.env['HTTP_REFERER'] = hosts_path

        params = { :host_ids => @hosts.map(&:id),
                   :proxy => { :proxy_id => '' } }

        post :update_multiple_salt_master, params: params,
          session: set_session_user.merge(:user => users(:admin).id)

        assert_empty flash[:error]

        @hosts.each do |host|
          as_admin do
            assert_nil host.reload.salt_proxy
          end
        end
      end
    end

    describe "setting salt environment on multiple hosts" do
      before do
        setup_user "edit"
        as_admin do
          @hosts = FactoryBot.create_list(:host, 2)
          @proxy = FactoryBot.create(:smart_proxy, :with_salt_feature)
          @salt_environment = FactoryBot.create :salt_environment
        end
      end

      test 'user without edit permission should not be able to change salt environment' do
        @request.env['HTTP_REFERER'] = hosts_path

        params = { :host_ids => @hosts.map(&:id),
                   :salt_environment => { :id => @salt_environment.id } }

        post :update_multiple_salt_environment, params: params,
        session: set_session_user.merge(:user => users(:one).id)
        assert_response :forbidden
      end

      test "should change the salt environment" do
        @request.env['HTTP_REFERER'] = hosts_path

        params = { :host_ids => @hosts.map(&:id),
                   :salt_environment => { :id => @salt_environment.id } }

        post :update_multiple_salt_environment, params: params,
        session: set_session_user.merge(:user => users(:admin).id)

        assert_empty flash[:error]

        @hosts.each do |host|
          as_admin do
            assert_equal @salt_environment, host.reload.salt_environment
          end
        end
      end

      test "should clear the salt environment of multiple hosts" do
        @request.env['HTTP_REFERER'] = hosts_path

        params = { :host_ids => @hosts.map(&:id),
                   :salt_environment => { :id => '' } }

        post :update_multiple_salt_environment, params: params,
          session: set_session_user.merge(:user => users(:admin).id)

        assert_empty flash[:error]

        @hosts.each do |host|
          as_admin do
            assert_nil host.reload.salt_environment
          end
        end
      end
    end
  end
end
