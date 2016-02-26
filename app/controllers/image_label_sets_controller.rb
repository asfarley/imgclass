class ImageLabelSetsController < ApplicationController
  before_action :set_image_label_set, only: [:show, :edit, :update, :destroy]
  require 'fileutils'
  require 'pathname'
  require 'kaminari'
  require 'fastimage'
  require 'zip'
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
    FileUtils::mkdir_p "/srv/imgclass/public/images/#{image_set.id}"
    @image_label_set.image_set_id = image_set.id
    params["upload"].each do |uf|
      fs = FastImage.size(uf.tempfile.path)
      if (fs[0] >= Rails.configuration.x.image_upload.mindimension) and (fs[1] >= Rails.configuration.x.image_upload.mindimension)
        i = Image.new
        new_path = "/srv/imgclass/public/images/#{image_set.id}/" + uf.original_filename.to_s
        FileUtils.mv(uf.tempfile.path, new_path)
        i.url = "/images/#{image_set.id}/" + uf.original_filename.to_s
        i.image_set_id = @image_label_set.image_set_id
        i.save
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
    ils = ImageLabelSet.find(params[:id]).image_set.images.each do |image|
      il = ImageLabel.new()
      il.image = image
      il.save
    end
    redirect_to action: "index"
  end

  def download
    fileLabelsString=""
    downloadString = ImageLabelSet.find(params[:id]).fileLabelPairs.inject("") {|fileLabelString,fileLabelPair| fileLabelString + "\"" + fileLabelPair["url"] + "\" " + fileLabelPair["label"] + "\r\n"}
    labelsPath = "/tmp/labels.txt"
    File.open(labelsPath, 'w+') {|f| f.write(downloadString) }
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
      #zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
    end

    send_file zipfile_name, :filename => "trainingset.zip", disposition: 'attachment'
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
