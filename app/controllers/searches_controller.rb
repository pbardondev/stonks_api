class SearchesController < ApplicationController
  before_action :set_search, only: [:show, :update, :destroy]

  # GET /searches
  def index
    @searches = Search.all

    render json: @searches
  end

  # GET /searches/1
  def show
    @search = Search.find(params[:id])
  end

  # POST /searches
  def create
    @search = Search.new(search_params)
    # Validate the object first
    unless @search.valid?
      render json: @search.errors, status: :bad_request
      return
    end

    if @search.exists?
      render json: "Search for this ticker on this date has already been performed", status: :conflict
      return
    end

    results = @search.query_external_api

    # Ensure we got results from the API
    unless results
      render json: 'Unable to retrieve query results', status: :internal_server_error
      return
    end

    # Associate the search with the company
    @search.company = Company.find_by_ticker(@search.ticker)
    if @search.save
      render status: :created
    else
      render json: @search.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /searches/1
  def update
    if @search.update(search_params)
      render json: @search
    else
      render json: @search.errors, status: :unprocessable_entity
    end
  end

  # DELETE /searches/1
  def destroy
    @search.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def search_params
      params.require(:search).permit(:ticker, :date)
    end
end
