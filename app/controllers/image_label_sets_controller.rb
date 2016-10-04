class ImageLabelSetsController < ApplicationController
  before_action :set_image_label_set, only: [:show, :edit, :update, :destroy]
  require 'fileutils'
  require 'pathname'
  require 'kaminari'
  require 'fastimage'
  require 'zip'
  require 'pry'

  require 'image_file_utils'
  include ImageFileUtils
  
  # GET /image_label_sets
  # GET /image_label_sets.json
  def index
    @image_label_sets = ImageLabelSet.all
  end

  # GET /image_label_sets/1
  # GET /image_label_sets/1.json
  def show
    if params.has_key?(:page)
      @images = Kaminari.paginate_array(@image_label_set.image_set.images).page(params[:page])
    else
      @images = Kaminari.paginate_array(@image_label_set.image_set.images).page(1)
    end
  end

  # GET /image_label_sets/new
  def new
    @image_label_set = ImageLabelSet.new
    @image_label_set.image_set = ImageSet.new
    @image_label_set.label_set = LabelSet.new
  end

  # GET /image_label_sets/1/edit
  def edit
  end

  # POST /image_label_sets
  # POST /image_label_sets.json
  def create
    @image_label_set = ImageLabelSet.new

    label_set = LabelSet.new
    label_set.save
    @image_label_set.label_set_id = label_set.id
    params["labels"].split(",").each do |l|
      lb = Label.new
      lb.text = l
      lb.label_set_id = @image_label_set.label_set_id
      lb.save
    end

    image_set = ImageSet.new
    image_set.save
    FileUtils::mkdir_p image_set.local_dir
    @image_label_set.image_set_id = image_set.id

    params["upload"].each do |uf|
      #Check if zipfile or raw images
      if (File.extname(uf.tempfile.path)==".zip")
        Zip::File.open(uf.tempfile.path) do |zipfile|
        zipfile.each do |file|
          if(file.ftype == :file)
            new_path = "/srv/imgclass/public/images/#{image_set.id}/" + File.basename(file.name)
            zipfile.extract(file, new_path) unless File.exist?(new_path)
            fs = FastImage.size(new_path)
            if (fs[0] >= Rails.configuration.x.image_upload.mindimension) and (fs[1] >= Rails.configuration.x.image_upload.mindimension)
              i = Image.new
              i.url = "/images/#{image_set.id}/" + File.basename(file.name)
              i.image_set_id = @image_label_set.image_set_id
              i.save
            else
              FileUtils.rm(new_path)
            end
          end
          end
        end
      else
        fs = FastImage.size(uf.tempfile.path)
        if (fs[0] >= Rails.configuration.x.image_upload.mindimension) and (fs[1] >= Rails.configuration.x.image_upload.mindimension)
          i = Image.new
          new_path = "/srv/imgclass/public/images/#{image_set.id}/" + uf.original_filename.to_s
          FileUtils.mv(uf.tempfile.path, new_path)
          i.url = "/images/#{image_set.id}/" + uf.original_filename.to_s
          i.image_set_id = @image_label_set.image_set_id
          i.save
        end
      end
      uf.tempfile.close
      uf.tempfile.unlink
    end

    respond_to do |format|
      if (@image_label_set.save)
        format.html { redirect_to @image_label_set, notice: 'Image label set was successfully created.' }
        format.json { render :show, status: :created, location: @image_label_set }
      else
        format.html { render :new }
        format.json { render json: @image_label_set.errors, status: :unprocessable_entity }
      end
    end
  end

  def makejob
    #Create a new ImageLabel for each image in this set
    #TODO: Rename this function since it's not actually creating/manipulating Job objects
    ils = ImageLabelSet.find(params[:id]).image_set.images.each do |image|
      il = ImageLabel.new()
      il.image = image
      il.save
    end
    redirect_to action: "index"
  end

  def download
    fileLabelsString=""
    labelsPath = ImageLabelSet.find(params[:id]).generateLabelsTextfile
    image_set_id = ImageLabelSet.find(params[:id]).image_set.id
    folder = "/srv/imgclass/public/images/#{image_set_id}"
    input_filenames = Dir.entries(folder) - %w(. ..)
    zipfile_name = "/tmp/trainingset.zip"
    FileUtils.rm_rf(zipfile_name)
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, folder + '/' + filename)
      end
      zipfile.add("labels.txt", labelsPath)
    end

    send_file zipfile_name, :filename => "trainingset.zip", disposition: 'attachment'
  end

  def assign
    @image_label_set = ImageLabelSet.find(params[:id])
    @workers = User.all
    @openjobs = Job.all.select{|j| j.isOpen}
    @completedjobs = Job.all.select{|j| j.isComplete}
    @job = Job.new
  end

  def createjob
    #Create a new Job
    j = Job.new

    #Assign this job to worker
    j.user_id = params[:userid]
    j.save

    #Get the next N image_labels for this image_label_set
    ims = ImageLabelSet.find(params[:id])
    batch = ims.batchOfRemainingLabels(5000)
    #Assign the next N image_labels to this job

    batch.each do |il|
      il.job_id = j.id
      il.save
    end

    #binding.pry

    redirect_to action: "assign", id: params[:id]
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
