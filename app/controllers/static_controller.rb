class StaticController < ApplicationController

  def index
    if current_user then
      redirect_to url_for(:controller => 'image_sets', :action=>'index')
    end 
  end
  
end
