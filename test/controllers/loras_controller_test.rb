require "test_helper"

class LorasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lora = loras(:one)
  end

  test "should get index" do
    get loras_url
    assert_response :success
  end

  test "should get new" do
    get new_lora_url
    assert_response :success
  end

  test "should create lora" do
    assert_difference("Lora.count") do
      post loras_url, params: { lora: { model_id: @lora.model_id, name: @lora.name, scale: @lora.scale, trigger: @lora.trigger, url_src: @lora.url_src } }
    end

    assert_redirected_to lora_url(Lora.last)
  end

  test "should show lora" do
    get lora_url(@lora)
    assert_response :success
  end

  test "should get edit" do
    get edit_lora_url(@lora)
    assert_response :success
  end

  test "should update lora" do
    patch lora_url(@lora), params: { lora: { model_id: @lora.model_id, name: @lora.name, scale: @lora.scale, trigger: @lora.trigger, url_src: @lora.url_src } }
    assert_redirected_to lora_url(@lora)
  end

  test "should destroy lora" do
    assert_difference("Lora.count", -1) do
      delete lora_url(@lora)
    end

    assert_redirected_to loras_url
  end
end
