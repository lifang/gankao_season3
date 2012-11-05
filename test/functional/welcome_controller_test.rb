require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test "should get welcome/index" do
    get :welcome/index
    assert_response :success
  end

end
