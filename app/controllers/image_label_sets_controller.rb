class ImageLabelSetsController < ApplicationController
  before_action :set_image_label_set, only: [:show, :edit, :update, :destroy]

  # GET /image_label_sets
  # GET /image_label_sets.json
  def index
    @image_label_sets = ImageLabelSet.all
  end

  # GET /image_label_sets/1
  # GET /image_label_sets/1.json
  def show
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
    @image_label_set = ImageLabelSet.new(image_label_set_params)

    respond_to do |format|
      if @image_label_set.save
        format.html { redirect_to @image_label_set, notice: 'Image label set was successfully created.' }
        format.json { render :show, status: :created, location: @image_label_set }
      else
        format.html { render :new }
        format.json { render json: @image_label_set.errors, status: :unprocessable_entity }
      end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_label_set
      @image_label_set = ImageLabelSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_label_set_params
      params.require(:image_label_set).permit(:image_set_id, :label_set_id, :user_id)
    end
end
