class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]
  before_action :set_image_label_set, only: [:new]
  before_filter :check_roles

  require 'kaminari'

  # GET /jobs
  # GET /jobs.json
  def index
    #@jobs = Job.all

  if current_user
    @jobs = current_user.jobs
  else
    redirect_to new_user_session_path, notice: 'You are not logged in.'
  end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    #params.delete :id
    #redirect_to "/image_label_sets"
    #@unlabeled = Job.find(params[:id]).image_labels.select{ |il| il.label.nil? }.first
    #@unlabeled = ImageLabel.where("label_id IS ?", nil).first
    #if @unlabeled.nil? then redirect_to action: "index" end

    if params.has_key?(:page)
      @images = Kaminari.paginate_array(@job.image_labels.map{ |il| il.image }).page(params[:page])
    else
      @images = Kaminari.paginate_array(@job.image_labels.map{ |il| il.image }).page(1)
    end
  end

  # GET /jobs/new
  def new
    if(current_user.nil?)
      redirect_to action: "index"
    else
      @job = Job.new
      @job.image_label_set_id = @image_label_set.id
      @job.user_id = current_user.id
    end
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(job_params)
    save_response = @job.save
    unlabelled_images = @job.image_label_set.batchOfRemainingLabels(Job::MAX_JOB_SIZE, @job.id)

    respond_to do |format|
      if save_response
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1
  # PATCH/PUT /jobs/1.json
  def update
    respond_to do |format|
      if @job.update(job_params)
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job.destroy
    respond_to do |format|
      format.html { redirect_to jobs_url, notice: 'Job was successfully destroyed.' }
      format.json { head :no_content }
    end
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
    def set_job
      @job = Job.find(params[:id])
    end

    def set_image_label_set
      @image_label_set = ImageLabelSet.find(params[:image_label_set_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:image_label_set_id, :user_id)
    end
end
