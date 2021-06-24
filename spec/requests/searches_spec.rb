# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/searches', type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Search. As you add validations to Search, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    FactoryBot.build(:search).attributes.symbolize_keys
  end

  let(:invalid_attributes) do
    { ticker: 'AAPFDSASDFGL' }
  end

  let(:api_connector) do
    instance_double(Apis::FinancialModelingPrepApi)
  end

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # SearchesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) { {} }

  describe 'GET /index' do
    it 'renders a successful response' do
      Search.create! valid_attributes
      get searches_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end

    it 'returns the list of searches' do
      5.times do
        create(:search)
      end
      get searches_url, headers: valid_headers, as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body).length).to eq(5)
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      search = Search.create! valid_attributes
      get search_url(search), as: :json
      expect(response).to be_successful
    end

    it 'renders price and company information' do
      search = create(:search)
      company = company_with_prices
      search.company = company
      search.save!
      get search_url(search), as: :json
      expect(response).to be_successful
      parsed = JSON.parse(response.body)
      expect(parsed['ticker']).to_not be_nil
      expect(parsed['company']).to_not be_nil
      expect(parsed['company']['prices']).to_not be_nil
      expect(parsed['company']['prices'][0]['open']).to_not be_nil
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Search' do
        expect do
          historical_prices = JSON.parse(File.open(
            "#{Rails.root}/spec/data/aapl_historical.json"
          ).read)
    
          historical_prices['symbol'] = valid_attributes[:ticker]
    
          allow(Apis::FinancialModelingPrepApi)
            .to receive(:new)
            .and_return(api_connector)
    
          allow(api_connector)
            .to receive(:find)
            .and_return(historical_prices)

          
          post searches_url,
               params: { search: valid_attributes }, headers: valid_headers, as: :json
        end.to change(Search, :count).by(1)
      end

      it 'renders a JSON response with the new search' do
        results = get_mock_price_data('aapl_historical.json')
        results['symbol'] = valid_attributes[:ticker]
        Apis::Api.subclasses.each do |klass|
          allow_any_instance_of(klass).to receive(:query).and_return(results)
        end

        post searches_url,
             params: { search: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Search' do
        expect do
          post searches_url,
               params: { search: invalid_attributes }, as: :json
        end.to change(Search, :count).by(0)
      end

      it 'renders a JSON response with errors for the new search' do
        post searches_url,
             params: { search: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'does not allow duplicate searches' do
      it 'prevents the user from creating a duplicate search' do
        results = get_mock_price_data('aapl_historical.json')
        results['symbol'] = 'DDD'
        Apis::Api.subclasses.each do |klass|
          allow_any_instance_of(klass).to receive(:query).and_return(results)
        end

        post searches_url,
             params: { search: valid_attributes.update(ticker: 'DDD') },
             headers: valid_headers,
             as: :json
        expect(response).to have_http_status(:created)

        post searches_url,
             params: { search: valid_attributes.update(ticker: 'DDD') },
             headers: valid_headers,
             as: :json
        expect(response).to have_http_status(:conflict)
      end
    end

    context 'returns the company that we were searching for' do
      it 'returns the company information in the search result JSON body' do
        results = get_mock_price_data('aapl_historical.json')
        results['symbol'] = valid_attributes[:ticker]
        Apis::Api.subclasses.each do |klass|
          allow_any_instance_of(klass).to receive(:query).and_return(results)
        end

        attributes = valid_attributes
        post searches_url,
             params: { search: attributes },
             headers: valid_headers,
             as: :json
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body['ticker']).to eq(attributes[:ticker])
        expect(Company.find_by_ticker(body['ticker']).ticker).to eq(attributes[:ticker])
        expect(body['company']['prices']).to_not be_nil
      end
    end
  end

  describe 'PATCH /update' do
    new_stock_ticker = 'AAPL'
    context 'with valid parameters' do
      let(:new_attributes) do
        new_attributes = valid_attributes
        new_attributes.update(ticker: new_stock_ticker)
        new_attributes
      end

      it 'updates the requested search' do
        search = Search.create! valid_attributes
        patch search_url(search),
              params: { search: new_attributes }, headers: valid_headers, as: :json
        search.reload
        expect(search.ticker).to eq(new_stock_ticker)
      end

      it 'renders a JSON response with the search' do
        search = Search.create! valid_attributes
        patch search_url(search),
              params: { search: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the search' do
        search = Search.create! valid_attributes
        patch search_url(search),
              params: { search: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested search' do
      search = Search.create! valid_attributes
      expect do
        delete search_url(search), headers: valid_headers, as: :json
      end.to change(Search, :count).by(-1)
    end
  end
end
