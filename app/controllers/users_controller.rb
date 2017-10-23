class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  before_filter :check_roles

  #Show all users
  def index
    @users = User.all
  end

  #Show a particular user
  def show
    @worksample = (@user.image_labels.select{ |il| not il.target.nil?}.sort_by &:created_at).reverse().take(10)
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

  def check_roles
    if(current_user.roles.nil?)
      redirect_to '/'
    end

    if not current_user.roles.include? "admin"
      redirect_to '/'
    end
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
