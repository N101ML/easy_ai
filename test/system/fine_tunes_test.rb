require "application_system_test_case"

class FineTunesTest < ApplicationSystemTestCase
  setup do
    @fine_tune = fine_tunes(:one)
  end

  test "visiting the index" do
    visit fine_tunes_url
    assert_selector "h1", text: "Fine tunes"
  end

  test "should create fine tune" do
    visit fine_tunes_url
    click_on "New fine tune"

    fill_in "Model", with: @fine_tune.model_id
    fill_in "Name", with: @fine_tune.name
    fill_in "Platform", with: @fine_tune.platform
    fill_in "Platform link", with: @fine_tune.platform_link
    fill_in "Platform source", with: @fine_tune.platform_source
    click_on "Create Fine tune"

    assert_text "Fine tune was successfully created"
    click_on "Back"
  end

  test "should update Fine tune" do
    visit fine_tune_url(@fine_tune)
    click_on "Edit this fine tune", match: :first

    fill_in "Model", with: @fine_tune.model_id
    fill_in "Name", with: @fine_tune.name
    fill_in "Platform", with: @fine_tune.platform
    fill_in "Platform link", with: @fine_tune.platform_link
    fill_in "Platform source", with: @fine_tune.platform_source
    click_on "Update Fine tune"

    assert_text "Fine tune was successfully updated"
    click_on "Back"
  end

  test "should destroy Fine tune" do
    visit fine_tune_url(@fine_tune)
    click_on "Destroy this fine tune", match: :first

    assert_text "Fine tune was successfully destroyed"
  end
end
