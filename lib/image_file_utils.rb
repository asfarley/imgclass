module ImageFileUtils

    def dir_for_set(id)

        return Rails.configuration.x.image_upload.rootDir + "/#{id}/"
    end

    # virtual dir for image set
    def vdir_for_set(id)
        return "/images/#{id}/"
    end

end