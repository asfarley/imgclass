require 'test_helper'

class ImageLabelsControllerTest < ActionController::TestCase
  setup do
    @image_label = image_labels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:image_labels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create image_label" do
    assert_difference('ImageLabel.count') do
      post :create, image_label: { image_id: @image_label.image_id, label_id: @image_label.label_id, user_id: @image_label.user_id }
    end

    assert_redirected_to image_label_path(assigns(:image_label))
  end

  test "should show image_label" do
    get :show, id: @image_label
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @image_label
    assert_response :success
  end

  test "should update image_label" do
    patch :update, id: @image_label, image_label: { image_id: @image_label.image_id, label_id: @image_label.label_id, user_id: @image_label.user_id }
    assert_redirected_to image_label_path(assigns(:image_label))
  end

  test "should destroy image_label" do
    assert_difference('ImageLabel.count', -1) do
      delete :destroy, id: @image_label
    end

    assert_redirected_to image_labels_path
  end
end
