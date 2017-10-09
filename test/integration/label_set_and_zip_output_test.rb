require 'test_helper'
require 'zip'

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
    # Attempt to generate output
    ils = ImageLabelSet.first
    ils.generate_output_folder_if_complete
    # Extract zipped folder
    expected_zipfile_name = File.join(Rails.root, "tmp", "ImageLabelSet_#{ils.id}.zip")
    unzip_destination = File.join(Rails.root, "tmp", "WorkingTrainingSet")
    assert File.exist?(expected_zipfile_name), "Output zipfile does not exist after attempting to generate."
    Zip::File.open(expected_zipfile_name) { |zip_file|
     zip_file.each { |f|
       f_path=File.join(unzip_destination, f.name)
       FileUtils.mkdir_p(File.dirname(f_path))
       zip_file.extract(f, f_path) unless File.exist?(f_path)
      }
    }
    # Launch YOLOV2 training process

    # Check that training does not fail with error
    
    assert false, "Test not implemented"
  end

end
