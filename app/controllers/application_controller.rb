class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_raven_context

  def after_sign_in_path_for(admin)
    if(current_user.roles.nil?)
      return "/image_labels/next"
    end
    if(not current_user.roles.include? "admin")
      return "/image_labels/next"
    end
    image_label_sets_url
  end

  private

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

end
