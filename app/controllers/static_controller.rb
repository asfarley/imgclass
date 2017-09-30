class StaticController < ApplicationController

  def index
    if(!current_user.nil?)
      if (not current_user.roles.nil?)
        if current_user.roles.include? "admin"
          redirect_to image_label_sets_url
        end
      end
    end
  end

end
