class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  #Show all users
  def index
  end

  #Show a particular user
  def show
  end

  #Update a particular user's properties
  def update
  end

  #Destroy a user
  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:roles)
    end
end
