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
    post :create, params: {:hostname => {:name => nil}}, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    post :create, params: {:hostname => {:name => "MySmartProxy", :hostname => "nowhere.org"}}, session: set_session_user
    assert_redirected_to hostnames_url
  end

  def test_edit
    get :edit, params: {:id => SmartProxyPool.first}, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    SmartProxyPool.any_instance.stubs(:valid?).returns(false)
    put :update, params: {:id => SmartProxyPool.first.to_param, :hostname => {:hostname => nil}}, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    put :update, params: {:id => SmartProxyPool.unscoped.first,
                  :hostname => {:hostname => "elsewhere.org"}}, session: set_session_user
    assert_equal "elsewhere.org", SmartProxyPool.unscoped.first.hostname
    assert_redirected_to hostnames_url
  end

  def test_destroy
    hostname = SmartProxyPool.first
    delete :destroy, params: {:id => hostname}, session: set_session_user
    assert_redirected_to hostnames_url
    assert !SmartProxyPool.exists?(hostname.id)
  end

  test "should search by name" do
    @request.env["HTTP_REFERER"] = hostnames_url
    get :index, params: { :search => "name=\"#{hostnames(:one).name}\"" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:hostnames)
    assert assigns(:hostnames).include?(hostnames(:one))
  end

  test "should search by smart_proxy" do
    @request.env["HTTP_REFERER"] = hostnames_url
    get :index, params: { :search => "smart_proxy=\"#{smart_proxies(:one).name}\"" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:hostnames)
    assert assigns(:hostnames).include?(hostnames(:one))
  end
end
