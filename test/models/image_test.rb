require 'test_helper'

class ImageTest < ActiveSupport::TestCase

  def setup
    @im = Image.new()
    @im.save
    @bb_car1 = { :x => 0.1, :y => 0.1, :width => 0.1, :height => 0.1, :classname => "Car" }
    @bb_car2 = { :x => 0.6, :y => 0.6, :width => 0.1, :height => 0.1, :classname => "Car" }
    @il1 = ImageLabel.new()
    @il2 = ImageLabel.new()
    @il3 = ImageLabel.new()
    @il1.image_id = @im.id
    @il2.image_id = @im.id
    @il3.image_id = @im.id
    @targets_list_two_cars = [@bb_car1, @bb_car2]
    @targets_list_three_cars = [@bb_car1, @bb_car2, @bb_car2]
    @targets_list_nothing = []
  end

  test "most_likely_bounding_boxes returns nearest-to-average target (1)" do
    targetJSON1 = @targets_list_two_cars.to_json
    targetJSON2 = @targets_list_nothing.to_json

    @il1.target = targetJSON2
    @il2.target = targetJSON1
    @il3.target = targetJSON1

    @il1.save
    @il2.save
    @il3.save

    assert (@im.most_likely_bounding_boxes == targetJSON1)
  end

  test "most_likely_bounding_boxes returns nearest-to-average target (2)" do
    targetJSON1 = @targets_list_two_cars.to_json
    targetJSON2 = @targets_list_nothing.to_json

    @il1.target = targetJSON2
    @il2.target = targetJSON2
    @il3.target = targetJSON1

    @il1.save
    @il2.save
    @il3.save

    assert (@im.most_likely_bounding_boxes == targetJSON2)
  end

  test "most_likely_bounding_boxes returns nearest-to-average target (3)" do
    targetJSON1 = @targets_list_two_cars.to_json
    targetJSON2 = @targets_list_nothing.to_json
    targetJSON3 = @targets_list_three_cars.to_json

    # Although targetJSON3 is present twice while the other targets are present only once,
    # targetJSON2 is selected since it's closest to the average: (0 + 3 + 3 + 2)/4 = 2
    @il1.target = targetJSON1
    @il2.target = targetJSON2
    @il3.target = targetJSON3
    il4 = ImageLabel.new
    il4.id = @im.id
    il4.target = targetJSON3

    @il1.save
    @il2.save
    @il3.save
    il4.save

    assert(@im.most_likely_bounding_boxes == targetJSON1)
  end

  test "most_likely_bounding_boxes returns single target" do
    targetJSON1 = @targets_list_two_cars.to_json

    @il1.target = targetJSON1

    @il1.save
    @il2.delete
    @il3.delete

    assert (@im.most_likely_bounding_boxes == targetJSON1)
  end

end
