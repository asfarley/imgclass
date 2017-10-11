require 'test_helper'
require './app/lib/yolofilegenerator'

class YoloFileGeneratorTest < ActiveSupport::TestCase


  test "All Yolo configuration and training files are successfully generated" do
    #Generate labels list
    labels = ["Car", "Person", "Truck", "Bus", "Motorcycle", "Bicycle"]
    #Generate images list
    images = []
    for i in 1..1000
      images.push("image_#{i}.jpg")
    end
    directory = "./tmp/yolocfg/"
    YoloFileGenerator.generate_all_yolo_training_files(directory,images,labels)

    assert File.exist?("./tmp/yolocfg/train.txt"), "train.txt is missing"
    assert File.exist?("./tmp/yolocfg/test.txt"), "test.txt is missing"
    assert File.exist?("./tmp/yolocfg/obj.data"), "obj.data is missing"
    assert File.exist?("./tmp/yolocfg/obj.names"), "obj.names is missing"
    assert File.exist?("./tmp/yolocfg/yolo-obj.cfg"), "yolo-obj.cfg is missing"
  end

end
