require 'test_helper'

class InvestmentTagsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get investment_tags_new_url
    assert_response :success
  end

  test "should get create" do
    get investment_tags_create_url
    assert_response :success
  end

  test "should get edit" do
    get investment_tags_edit_url
    assert_response :success
  end

  test "should get update" do
    get investment_tags_update_url
    assert_response :success
  end

  test "should get destroy" do
    get investment_tags_destroy_url
    assert_response :success
  end

end
