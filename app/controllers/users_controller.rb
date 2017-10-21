class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  #Show all users
  def index
    @users = User.all
  end

  #Show a particular user
  def show
  end

  def edit
  end

  #Update a particular user's properties
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User roles were successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
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
