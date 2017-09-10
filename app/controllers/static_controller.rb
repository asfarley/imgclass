class StaticController < ApplicationController

  def index
    if(!current_user.nil?)
      redirect_to image_label_sets_url
    end
  end

end
