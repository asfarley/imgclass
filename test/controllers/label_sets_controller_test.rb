require 'test_helper'

class LabelSetsControllerTest < ActionController::TestCase
  setup do
    @label_set = label_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:label_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create label_set" do
    assert_difference('LabelSet.count') do
      post :create, label_set: {  }
    end

    assert_redirected_to label_set_path(assigns(:label_set))
  end

  test "should show label_set" do
    get :show, id: @label_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @label_set
    assert_response :success
  end

  test "should update label_set" do
    patch :update, id: @label_set, label_set: {  }
    assert_redirected_to label_set_path(assigns(:label_set))
  end

  test "should destroy label_set" do
    assert_difference('LabelSet.count', -1) do
      delete :destroy, id: @label_set
    end

    assert_redirected_to label_sets_path
  end
end
