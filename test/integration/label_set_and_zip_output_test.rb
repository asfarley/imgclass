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

end
