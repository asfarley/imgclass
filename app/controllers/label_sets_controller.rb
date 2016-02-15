class LabelSetsController < ApplicationController
  before_action :set_label_set, only: [:show, :edit, :update, :destroy]

  # GET /label_sets
  # GET /label_sets.json
  def index
    @label_sets = LabelSet.all
  end

  # GET /label_sets/1
  # GET /label_sets/1.json
  def show
  end

  # GET /label_sets/new
  def new
    @label_set = LabelSet.new
  end

  # GET /label_sets/1/edit
  def edit
  end

  # POST /label_sets
  # POST /label_sets.json
  def create
    @label_set = LabelSet.new(label_set_params)

    respond_to do |format|
      if @label_set.save
        format.html { redirect_to @label_set, notice: 'Label set was successfully created.' }
        format.json { render :show, status: :created, location: @label_set }
      else
        format.html { render :new }
        format.json { render json: @label_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /label_sets/1
  # PATCH/PUT /label_sets/1.json
  def update
    respond_to do |format|
      if @label_set.update(label_set_params)
        format.html { redirect_to @label_set, notice: 'Label set was successfully updated.' }
        format.json { render :show, status: :ok, location: @label_set }
      else
        format.html { render :edit }
        format.json { render json: @label_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /label_sets/1
  # DELETE /label_sets/1.json
  def destroy
    @label_set.destroy
    respond_to do |format|
      format.html { redirect_to label_sets_url, notice: 'Label set was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_label_set
      @label_set = LabelSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def label_set_params
      params.fetch(:label_set, {})
    end
end
