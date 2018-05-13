require 'test_helper'

class SourcesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sources_index_url
    assert_response :success
  end

  test "should get edit" do
    get sources_edit_url
    assert_response :success
  end

end
