# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PricesController, type: :routing do
  describe 'routing' do
    before(:all) do
      @company = create(:company)
    end

    after(:all) do
      @company.destroy!
    end

    it 'routes to #index' do
      expect(get: "/companies/#{@company.id}/prices")
        .to route_to('prices#index', company_id: @company.id.to_s)
    end

    it 'routes to #show' do
      expect(get: "/companies/#{@company.id}/prices/1")
        .to route_to('prices#show', company_id: @company.id.to_s, id: '1')
    end

    it 'routes to #create' do
      expect(post: "/companies/#{@company.id}/prices")
        .to route_to('prices#create', company_id: @company.id.to_s)
    end

    it 'routes to #update via PUT' do
      expect(put: "/companies/#{@company.id}/prices/1")
        .to route_to('prices#update', id: '1', company_id: @company.id.to_s)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/companies/#{@company.id}/prices/1")
        .to route_to('prices#update', id: '1', company_id: @company.id.to_s)
    end

    it 'routes to #destroy' do
      expect(delete: "/companies/#{@company.id}/prices/1")
        .to route_to('prices#destroy', id: '1', company_id: @company.id.to_s)
    end
  end
end
