require "test_helper"

class ItinerariesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get itineraries_index_url
    assert_response :success
  end

  test "should get create" do
    get itineraries_create_url
    assert_response :success
  end
end
