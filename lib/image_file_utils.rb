module ImageFileUtils

    def dir_for_set(id)

        return Rails.configuration.x.image_upload.rootDir + "/#{id}/"
    end

end