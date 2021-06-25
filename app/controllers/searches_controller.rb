# frozen_string_literal: true

## Search Controller used to create and manage searches and search results.
class SearchesController < ApplicationController
  before_action :set_search, only: %i[show update destroy]

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
    return unless search_valid?
    return unless query_successful?

    # Associate the search with the company
    @search.company = Company.find_by_ticker(@search.ticker)

    if @search.save
      render status: :created
    else
      render json: @search.errors, status: :unprocessable_entity
    end
  end

  private

  def query_successful?
    results = @search.query_external_api

    # Ensure we got results from the API
    unless results
      render json: 'Unable to retrieve query results', status: :internal_server_error
      return false
    end

    true
  end

  def search_valid?
    # Validate the object first
    unless @search.valid?
      render json: @search.errors, status: :bad_request
      return false
    end

    if @search.exists?
      render json: 'Search for this ticker on this date has already been performed', status: :conflict
      return false
    end

    true
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_search
    @search = Search.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def search_params
    params.require(:search).permit(:ticker, :date)
  end
end
