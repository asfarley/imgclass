class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(admin)
    if(current_user.roles.nil?)
      return "/image_labels/next"
    end
    if(not current_user.roles.include? "admin")
      return "/image_label/next"
    end
    image_label_sets_url
  end

end
