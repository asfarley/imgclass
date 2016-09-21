# only authenicated users are allowed to use the controller
class UserController < ApplicationController
    before_filter :validate_user

    def validate_user
        if ! current_user 
        render file: "#{Rails.root}/public/404.html", layout: false, status: 404
        end
    end
end