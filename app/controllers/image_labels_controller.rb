class ImageLabelsController < ApplicationController
  before_action :set_image_label, only: [:show, :edit, :update, :destroy]

  # GET /image_labels
  # GET /image_labels.json
  def index
    @image_labels = ImageLabel.all
  end

  def next
    @unlabeled = ImageLabel.where("label_id IS ?", nil).first
    if @unlabeled.nil? then redirect_to action: "outofwork" end
  end

  def outofwork
  end

  # GET /image_labels/1
  # GET /image_labels/1.json
  def show
  end

  # GET /image_labels/new
  def new
    @image_label = ImageLabel.new
  end

  # GET /image_labels/1/edit
  def edit
  end

  # POST /image_labels
  # POST /image_labels.json
  def create
    @image_label = ImageLabel.new(image_label_params)

    respond_to do |format|
      if @image_label.save
        format.html { redirect_to @image_label, notice: 'Image label was successfully created.' }
        format.json { render :show, status: :created, location: @image_label }
      else
        format.html { render :new }
        format.json { render json: @image_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /image_labels/1
  # PATCH/PUT /image_labels/1.json
  def update
    @job = ImageLabel.find(params[:id]).job
    respond_to do |format|
      if @image_label.update(image_label_params)
        format.html { redirect_to action: "next", notice: 'Image label was successfully updated.' }
        #format.html { redirect_to @job }
        format.json { render :show, status: :ok, location: @image_label }
      else
        format.html { render :edit }
        format.json { render json: @image_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_labels/1
  # DELETE /image_labels/1.json
  def destroy
    @image_label.destroy
    respond_to do |format|
      format.html { redirect_to image_labels_url, notice: 'Image label was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_label
      @image_label = ImageLabel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_label_params
      params.permit(:image_id, :label_id, :user_id)
    end
end
