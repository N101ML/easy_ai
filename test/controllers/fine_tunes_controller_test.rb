require "test_helper"

class FineTunesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fine_tune = fine_tunes(:one)
  end

  test "should get index" do
    get fine_tunes_url
    assert_response :success
  end

  test "should get new" do
    get new_fine_tune_url
    assert_response :success
  end

  test "should create fine_tune" do
    assert_difference("FineTune.count") do
      post fine_tunes_url, params: { fine_tune: { model_id: @fine_tune.model_id, name: @fine_tune.name, platform: @fine_tune.platform, platform_link: @fine_tune.platform_link, platform_source: @fine_tune.platform_source } }
    end

    assert_redirected_to fine_tune_url(FineTune.last)
  end

  test "should show fine_tune" do
    get fine_tune_url(@fine_tune)
    assert_response :success
  end

  test "should get edit" do
    get edit_fine_tune_url(@fine_tune)
    assert_response :success
  end

  test "should update fine_tune" do
    patch fine_tune_url(@fine_tune), params: { fine_tune: { model_id: @fine_tune.model_id, name: @fine_tune.name, platform: @fine_tune.platform, platform_link: @fine_tune.platform_link, platform_source: @fine_tune.platform_source } }
    assert_redirected_to fine_tune_url(@fine_tune)
  end

  test "should destroy fine_tune" do
    assert_difference("FineTune.count", -1) do
      delete fine_tune_url(@fine_tune)
    end

    assert_redirected_to fine_tunes_url
  end
end
