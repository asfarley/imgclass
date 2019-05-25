class ImageLabelSetsController < ApplicationController
  before_action :set_image_label_set, only: [:show, :edit, :update, :destroy, :admin, :assign_entire_set, :download, :refresh_zipfile, :label_with_blanks, :assign_remaining]
  require 'fileutils'
  require 'pathname'
  require 'kaminari'
  require 'fastimage'
  require 'zip'
  #require 'byebug'
  require './app/lib/zipfilegenerator'


  before_filter :check_roles

  # GET /image_label_sets
  # GET /image_label_sets.json
  def index
    if current_user.nil?
      redirect_to '/'
    end
    @image_label_sets = current_user.image_label_sets
  end

  # GET /image_label_sets/1
  # GET /image_label_sets/1.json
  def show
    if params.has_key?(:page)
      @images = Kaminari.paginate_array(@image_label_set.images).page(params[:page])
    else
      @images = Kaminari.paginate_array(@image_label_set.images).page(1)
    end
  end

  def admin
    if params.has_key?(:page)
      @jobs = Kaminari.paginate_array(@image_label_set.jobs).page(params[:page])
    else
      @jobs = Kaminari.paginate_array(@image_label_set.jobs).page(1)
    end
  end

  def assign_entire_set
    @image_label_set.assign_entire_set
    respond_to do |format|
        format.html { redirect_to @image_label_set, notice: 'Image label set was fully assigned.' }
    end
  end

  def assign_remaining
    @image_label_set.assign_remaining
    respond_to do |format|
        format.html { redirect_to @image_label_set, notice: 'Remaining images were assigned.' }
    end
  end

  def refresh_zipfile
    respond_to do |format|
        format.html { redirect_to image_label_sets_url, notice: "Zipfile for #{@image_label_set.name} is being refreshed." }
    end
    #GenerateZipfilesJob.perform_later
    GenerateZipfileJob.perform_later @image_label_set
  end

  # GET /image_label_sets/new
  def new
    @image_label_set = ImageLabelSet.new
  end

  # GET /image_label_sets/1/edit
  def edit
  end

  # POST /image_label_sets
  # POST /image_label_sets.json
  def create

    if current_user.nil?
      redirect_to '/'
    end

    if(params["labels"].nil?)
      respond_to do |format|
          format.html { redirect_to image_label_sets_url, error: 'Labels not present.' }
      end
      return
    end

    @image_label_set = ImageLabelSet.new
    @image_label_set.name = params["name"]
    @image_label_set.user_id = current_user.id
    save_success = @image_label_set.save

    params["labels"].split(",").each do |l|
      lb = Label.new
      lb.text = l
      lb.image_label_set_id = @image_label_set.id
      lb.save
    end

    images_folder_path = Rails.root.join('public', "images/#{@image_label_set.id}")
    FileUtils::mkdir_p images_folder_path

    accepted_formats = [".jpg", ".png", ".bmp"]

    params["upload"].each do |uf|
      #Check if zipfile, raw images or URL textfile
      if (File.extname(uf.tempfile.path)==".txt")
        Image.transaction do
          File.readlines(uf.tempfile.path).each do |line|
            i = Image.new
            i.url = line.strip
            i.image_label_set_id = @image_label_set.id
            i.save
          end
        end
      end
      uf.tempfile.close
      uf.tempfile.unlink
    end

    respond_to do |format|
      if save_success
        format.html { redirect_to @image_label_set, notice: 'Image label set was successfully created.' }
        format.json { render :show, status: :created, location: @image_label_set }
      else
        format.html { render :new }
        format.json { render json: @image_label_set.errors, status: :unprocessable_entity }
      end
    end
  end

  def download
    zipfile_name = @image_label_set.zipped_output_folder_name()
    send_file zipfile_name, :filename => "yolo_trainingset_#{@image_label_set.path_safe_name()}.zip", x_sendfile: true, disposition: 'attachment'
  end

  def assign
    @image_label_set = ImageLabelSet.find(params[:id])
    @workers = User.all
    @openjobs = Job.all.select{|j| j.isOpen}
    @completedjobs = Job.all.select{|j| j.isComplete}
    @job = Job.new
  end

  def label_with_blanks
    @image_label_set.label_with_blanks
    respond_to do |format|
        format.html { redirect_to image_label_sets_url, notice: 'Image label set has been labelled with blanks.' }
    end
  end

  # PATCH/PUT /image_label_sets/1
  # PATCH/PUT /image_label_sets/1.json
  def update
    respond_to do |format|
      if @image_label_set.update(image_label_set_params)
        format.html { redirect_to @image_label_set, notice: 'Image label set was successfully updated.' }
        format.json { render :show, status: :ok, location: @image_label_set }
      else
        format.html { render :edit }
        format.json { render json: @image_label_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_label_sets/1
  # DELETE /image_label_sets/1.json
  def destroy
    @image_label_set.destroy
    respond_to do |format|
      format.html { redirect_to image_label_sets_url, notice: 'Image label set was successfully destroyed.' }
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
    def set_image_label_set
      @image_label_set = ImageLabelSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_label_set_params
      params.permit!
      #params.require(:image_label_set).permit(:image_set_id, :label_set_id, :user_id)
    end
end
