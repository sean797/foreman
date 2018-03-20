require 'test_helper'

class SmartProxyPoolsControllerTest < ActionController::TestCase
  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, session: set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    SmartProxyPool.any_instance.stubs(:valid?).returns(false)
    post :create, params: {:pool => {:name => nil}}, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    post :create, params: {:pool => {:name => "MySmartProxy", :pool => "nowhere.org"}}, session: set_session_user
    assert_redirected_to pools_url
  end

  def test_edit
    get :edit, params: {:id => SmartProxyPool.first}, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    SmartProxyPool.any_instance.stubs(:valid?).returns(false)
    put :update, params: {:id => SmartProxyPool.first.to_param, :pool => {:pool => nil}}, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    put :update, params: {:id => SmartProxyPool.unscoped.first,
                  :pool => {:pool => "elsewhere.org"}}, session: set_session_user
    assert_equal "elsewhere.org", SmartProxyPool.unscoped.first.pool
    assert_redirected_to pools_url
  end

  def test_destroy
    pool = SmartProxyPool.first
    delete :destroy, params: {:id => pool}, session: set_session_user
    assert_redirected_to pools_url
    assert !SmartProxyPool.exists?(pool.id)
  end

  test "should search by name" do
    @request.env["HTTP_REFERER"] = pools_url
    get :index, params: { :search => "name=\"#{smart_proxy_pools(:one).name}\"" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:pools)
    assert assigns(:pools).include?(smart_proxy_pools(:one))
  end

  test "should search by smart_proxy" do
    @request.env["HTTP_REFERER"] = pools_url
    get :index, params: { :search => "smart_proxy=\"#{smart_proxies(:one).name}\"" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:pools)
    assert assigns(:pools).include?(smart_proxy_pools(:one))
  end
end
