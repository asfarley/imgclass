class StaticController < ApplicationController

  def index
    if user_signed_in? then
      redirect_to url_for(:controller => 'image_label_sets', :action=>'index')
    end 
  end
  
end
