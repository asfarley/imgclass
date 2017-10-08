class GenerateZipfilesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    ImageLabelSet.all.each { |image_label_set|
      image_label_set.generate_output_folder_if_complete()
    }
  end
end
