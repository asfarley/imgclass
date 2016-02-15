require 'test_helper'

class ImageSetsControllerTest < ActionController::TestCase
  setup do
    @image_set = image_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:image_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create image_set" do
    assert_difference('ImageSet.count') do
      post :create, image_set: {  }
    end

    assert_redirected_to image_set_path(assigns(:image_set))
  end

  test "should show image_set" do
    get :show, id: @image_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @image_set
    assert_response :success
  end

  test "should update image_set" do
    patch :update, id: @image_set, image_set: {  }
    assert_redirected_to image_set_path(assigns(:image_set))
  end

  test "should destroy image_set" do
    assert_difference('ImageSet.count', -1) do
      delete :destroy, id: @image_set
    end

    assert_redirected_to image_sets_path
  end
end
