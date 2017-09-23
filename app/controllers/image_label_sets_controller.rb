class ImageLabelSetsController < ApplicationController
  before_action :set_image_label_set, only: [:show, :edit, :update, :destroy, :admin]
  require 'fileutils'
  require 'pathname'
  require 'kaminari'
  require 'fastimage'
  require 'zip'
  require 'byebug'
  # GET /image_label_sets
  # GET /image_label_sets.json
  def index
    @image_label_sets = ImageLabelSet.all
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
    @image_label_set = ImageLabelSet.new
    @image_label_set.bounding_box_mode = true
    @image_label_set.name = params["name"]
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
      #Check if zipfile or raw images
      if (File.extname(uf.tempfile.path)==".zip")
        Zip::File.open(uf.tempfile.path) do |zipfile|
        zipfile.each do |file|
          if(file.ftype == :file)
            extension = File.extname(file.name)
            basename = File.basename(file.name)
            if not accepted_formats.include? extension
              next #Ignore non-image files
            end
            if basename[0] == '.'
              next #This case catches some non-image files with image extensions created by OSX
            end
            new_path = images_folder_path + File.basename(file.name)
            zipfile.extract(file, new_path) unless File.exist?(new_path)
            fs = FastImage.size(new_path)
            if (fs[0] >= Rails.configuration.x.image_upload.mindimension) and (fs[1] >= Rails.configuration.x.image_upload.mindimension)
              i = Image.new
              i.url = "/images/#{@image_label_set.id}/" + File.basename(file.name)
              i.image_label_set_id = @image_label_set.id
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
          new_path = images_folder_path + uf.original_filename.to_s
          FileUtils.mv(uf.tempfile.path, new_path)
          i.url = "/images/#{@image_label_set.id}/" + uf.original_filename.to_s
          i.image_label_set_id = @image_label_set.id
          i.save
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

  def makejob
    #Create a new ImageLabel for each image in this set
    #TODO: Rename this function since it's not actually creating/manipulating Job objects
    ils = ImageLabelSet.find(params[:id]).images.each do |image|
      il = ImageLabel.new()
      #Get ID of signed-in user, if signed in (otherwise - bail, only logged-in users should be creating image labels)

      #Assign user id to image label
      #Assign job to image
      il.image = image
      il.save
    end
    redirect_to action: "index"
  end

  def download
    fileLabelsString=""
    labelsPath = ImageLabelSet.find(params[:id]).generateLabelsTextfile
    folder = File.join(Rails.root, "public", "images", "#{params[:id]}")
    input_filenames = Dir.entries(folder) - %w(. ..)
    zipfile_name = File.join(Rails.root, "tmp", "trainingset.zip")
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
