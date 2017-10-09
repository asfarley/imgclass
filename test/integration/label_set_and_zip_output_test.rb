require 'test_helper'

class LabelSetAndZipOutputTest < ActionDispatch::IntegrationTest

  test "A completely-labelled ImageLabelSet can generate a zipped output folder" do
     # Attempt to generate output
     ils = ImageLabelSet.first
     ils.generate_output_folder_if_complete
     # Check if output folder exists
     expected_zipfile_name = File.join(Rails.root, "tmp", "ImageLabelSet_#{ils.id}.zip")
     assert File.exist?(expected_zipfile_name), "Output zipfile does not exist after attempting to generate." 
  end

  test "A zipped output folder can be used to train YOLOV2" do
    # Extract zipped folder
    # Launch YOLOV2 training process
    # Check that training does not fail with error
    assert false, "Test not implemented"
  end

end
