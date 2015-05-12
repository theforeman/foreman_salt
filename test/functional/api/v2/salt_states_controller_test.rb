require 'test_plugin_helper'

module ForemanSalt
  class Api::V2::SaltStatesControllerTest < ActionController::TestCase
    test 'should get index' do
      get :index, {}
      assert_response :success
      assert_template 'api/v2/salt_states/index'
    end

    test 'should show state' do
      state = ForemanSalt::SaltModule.create(:name => 'foo.bar.baz')
      get :show, :id => state.id
      assert_response :success
      assert_template 'api/v2/salt_states/show'
    end

    test 'should create state' do
      post :create, :state => { :name => 'unicorn' }
      assert_response :success
      assert ForemanSalt::SaltModule.find_by_name('unicorn')
      assert_template 'api/v2/salt_states/create'
    end

    test 'should delete state' do
      state = ForemanSalt::SaltModule.create(:name => 'foo.bar.baz')
      assert_difference('ForemanSalt::SaltModule.count', -1) do
        delete :destroy, :id => state.id
      end
      assert_response :success
    end

    context 'importing' do
      setup do
        @proxy = FactoryGirl.create :smart_proxy, :with_salt_feature
        @states = {'env1' => %w(state1 state2 state3),
                   'env2' => %w(state1 state2)}

        ::ProxyAPI::Salt.any_instance.stubs(:states_list).returns(@states)
      end

      test 'should import' do
        post :import, :smart_proxy_id => @proxy.id

        assert_response :success

        @states.each do |env, states|
          environment = ::ForemanSalt::SaltEnvironment.find(env)
          assert_blank environment.salt_modules.map(&:name) - states
        end
      end

      test 'should import only from a given environment' do
        post :import, :smart_proxy_id => @proxy.id, :salt_environments => ['env2']
        assert_response :success
        refute ::ForemanSalt::SaltEnvironment.where(:name => 'env1').first
        assert ::ForemanSalt::SaltEnvironment.where(:name => 'env2').first
      end

      test 'should limit actions to add' do
        env   = FactoryGirl.create :salt_environment
        state = FactoryGirl.create :salt_module, :salt_environments => [env]

        post :import, :smart_proxy_id => @proxy.id, :actions => ['add']
        assert_response :success
        assert ::ForemanSalt::SaltModule.where(:id => state).first
        assert ::ForemanSalt::SaltModule.where(:name => 'state1').first
      end

      test 'should limit actions to remove' do
        state = FactoryGirl.create :salt_module
        post :import, :smart_proxy_id => @proxy.id, :actions => ['remove']
        assert_response :success
        refute ::ForemanSalt::SaltModule.where(:id => state).first
        refute ::ForemanSalt::SaltModule.where(:name => 'state1').first
       end

      test 'dryrun should do nothing' do
        post :import, :smart_proxy_id => @proxy.id, :dryrun => true
        assert_response :success
        refute ::ForemanSalt::SaltModule.all.any?
        refute ::ForemanSalt::SaltEnvironment.all.any?
      end
    end
  end
end
