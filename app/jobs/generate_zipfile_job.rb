class GenerateZipfileJob < ApplicationJob
  queue_as :default

  def perform(image_label_set)
    image_label_set.generate_output_folder_if_complete
  end
end
