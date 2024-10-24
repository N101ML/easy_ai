require "application_system_test_case"

class LorasTest < ApplicationSystemTestCase
  setup do
    @lora = loras(:one)
  end

  test "visiting the index" do
    visit loras_url
    assert_selector "h1", text: "Loras"
  end

  test "should create lora" do
    visit loras_url
    click_on "New lora"

    fill_in "Model", with: @lora.model_id
    fill_in "Name", with: @lora.name
    fill_in "Scale", with: @lora.scale
    fill_in "Trigger", with: @lora.trigger
    fill_in "Url src", with: @lora.url_src
    click_on "Create Lora"

    assert_text "Lora was successfully created"
    click_on "Back"
  end

  test "should update Lora" do
    visit lora_url(@lora)
    click_on "Edit this lora", match: :first

    fill_in "Model", with: @lora.model_id
    fill_in "Name", with: @lora.name
    fill_in "Scale", with: @lora.scale
    fill_in "Trigger", with: @lora.trigger
    fill_in "Url src", with: @lora.url_src
    click_on "Update Lora"

    assert_text "Lora was successfully updated"
    click_on "Back"
  end

  test "should destroy Lora" do
    visit lora_url(@lora)
    click_on "Destroy this lora", match: :first

    assert_text "Lora was successfully destroyed"
  end
end
