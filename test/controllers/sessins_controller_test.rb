require 'test_helper'

class SessinsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sessins_new_url
    assert_response :success
  end

end
