# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<AIRTABLE_API_KEY>') { ENV.fetch('AIRTABLE_API_KEY', 'AIRTABLE_API_KEY') }
end

# Mock transaction
class Transaction < Airrecord::Table
  self.api_key = ENV.fetch('AIRTABLE_API_KEY')
  self.base_key = 'appnzIqiDdK0Kew4f'
  self.table_name = 'Transactions'
end

RSpec.describe MonzoTransaction, type: :model do
  describe '#upsert_into_airtable' do
    let(:data) { JSON.parse(file_fixture('monzo_webhook_data.json').read)['data'] }

    subject(:monzo_transaction) { MonzoTransaction.new(metadata: data) }

    context 'when a record does not exist' do
      around { |example| VCR.use_cassette('airtable_absent', record: :new_episodes, &example) }

      it 'sends a request to create a new record' do
        allow(monzo_transaction).to receive(:existing_record).and_return(nil)
        monzo_transaction.save
        assert_requested :post, 'https://api.airtable.com/v0/appnzIqiDdK0Kew4f/Transactions'
      end
    end

    context 'when a record exists' do
      around { |example| VCR.use_cassette('airtable_present', record: :new_episodes, &example) }

      xit 'sends a request to update the existing record' do
        allow(monzo_transaction).to receive(:existing_record).and_return(OpenStruct.new(id: 'recp6MmMFNJ0BGdm8'))
        monzo_transaction.save
        assert_requested :patch, 'https://api.airtable.com/v0/appnzIqiDdK0Kew4f/Transactions'
      end
    end
  end
end
