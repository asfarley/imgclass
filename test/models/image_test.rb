require 'test_helper'

class ImageTest < ActiveSupport::TestCase

  def setup
    @im = Image.new()
    @im.save
    @bb1 = { :x => 0.1, :y => 0.1, :width => 0.1, :height => 0.1, :classname => "Car" }
    @bb2 = { :x => 0.6, :y => 0.6, :width => 0.1, :height => 0.1, :classname => "Car" }
  end

  test "most_likely_bounding_boxes returns consensus target" do
    il1 = ImageLabel.new()
    il2 = ImageLabel.new()
    il3 = ImageLabel.new()

    il1.image_id = @im.id
    il2.image_id = @im.id
    il3.image_id = @im.id

    targets_list = [@bb1, @bb2]

    targetJSON1 = targets_list.to_json
    targetJSON2 = "[]"

    il1.target = targetJSON2
    il2.target = targetJSON1
    il3.target = targetJSON1

    il1.save
    il2.save
    il3.save

    assert (@im.most_likely_bounding_boxes == targetJSON1)
  end

end
