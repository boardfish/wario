# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data('<AIRTABLE_API_KEY>') { ENV.fetch('AIRTABLE_API_KEY') }
end

RSpec.describe 'MonzoHookReceivers', type: :request do
  around { |example| VCR.use_cassette("airtable", record: :new_episodes, &example) }

  describe 'POST /transaction' do
    context 'with correct data' do
      subject(:request) do
        post '/monzo_hook_receiver/transaction', params: data, headers: { 'CONTENT_TYPE' => 'application/json' }
      end
      let(:data) { file_fixture('monzo_webhook_data.json').read }

      it 'returns http success' do
        request
        expect(response).to have_http_status(:success)
      end

      it 'creates a new MonzoTransaction' do
        expect { request }.to change(MonzoTransaction, :count).by(1)
      end

      it 'creates a MonzoTransaction with the right data' do
        request
        expect do
          MonzoTransaction.where("metadata ->> 'id' = :id", id: JSON.parse(data).dig('data', 'id')).limit(1).take!
        end.not_to raise_error
      end
    end
  end
end
