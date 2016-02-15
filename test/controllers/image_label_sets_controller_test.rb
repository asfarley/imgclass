require 'test_helper'

class ImageLabelSetsControllerTest < ActionController::TestCase
  setup do
    @image_label_set = image_label_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:image_label_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create image_label_set" do
    assert_difference('ImageLabelSet.count') do
      post :create, image_label_set: { image_set_id: @image_label_set.image_set_id, label_set_id: @image_label_set.label_set_id, user_id: @image_label_set.user_id }
    end

    assert_redirected_to image_label_set_path(assigns(:image_label_set))
  end

  test "should show image_label_set" do
    get :show, id: @image_label_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @image_label_set
    assert_response :success
  end

  test "should update image_label_set" do
    patch :update, id: @image_label_set, image_label_set: { image_set_id: @image_label_set.image_set_id, label_set_id: @image_label_set.label_set_id, user_id: @image_label_set.user_id }
    assert_redirected_to image_label_set_path(assigns(:image_label_set))
  end

  test "should destroy image_label_set" do
    assert_difference('ImageLabelSet.count', -1) do
      delete :destroy, id: @image_label_set
    end

    assert_redirected_to image_label_sets_path
  end
end
