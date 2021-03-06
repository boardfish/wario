# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<AIRTABLE_API_KEY>') { ENV.fetch('AIRTABLE_API_KEY', 'AIRTABLE_API_KEY') }
end

RSpec.describe MonzoTransaction, type: :model do
  def fetch_monzo_record(_id)
    Airrecord.table(
      ENV.fetch('AIRTABLE_API_KEY'), ENV.fetch('AIRTABLE_BASE'), 'Transactions'
    ).all(filter: "{Monzo ID} = '#{data['id']}'").first
  end

  # Mock airtable record.
  class AirtableRecord < OpenStruct
    def save
      Faraday.patch(
        "https://api.airtable.com/v0/#{ENV.fetch('AIRTABLE_BASE')}/Transactions",
        body: { records: [to_h.slice('id', 'fields')] }.to_json
      )
    end
  end

  subject(:monzo_transaction) { described_class.new(metadata: data) }

  before do
    ENV['AIRTABLE_API_KEY'] = 'AIRTABLE_API_KEY'
    ENV['AIRTABLE_BASE'] = 'appnzIqiDdK0Kew4f'
  end

  let(:data) { JSON.parse(file_fixture('monzo_webhook_data.json').read)['data'] }

  around { |example| VCR.use_cassette('airtable_transaction', record: :new_episodes, &example) }

  describe '#upsert_into_airtable' do
    subject(:save_action) do
      allow(monzo_transaction).to receive(:existing_record).and_return(record)
      monzo_transaction.save
    end

    context 'when a record does not exist' do
      let(:record) { nil }

      it 'sends a request to create a new record' do
        save_action
        assert_requested :post, 'https://api.airtable.com/v0/appnzIqiDdK0Kew4f/Transactions'
      end

      it 'sets the Month to the correct Month ID' do
        save_action
        expect(
          fetch_monzo_record(data['id'])['Month']
        ).to eq(['recZtH0Ot7PjORaao'])
      end
    end

    context 'when a record exists' do
      let(:record) do
        AirtableRecord.new(
          id: 'recI2lROdjAt0bz1m',
          created_at: DateTime.parse('2015-09-04T14:28:40.000Z'),
          updated_keys: [],
          fields: {
            'Monzo ID' => 'tx_00008zjky19HyFLAzlUk7t',
            'Amount' => -350,
            'Category' => [],
            'Month' => [],
            'Created' => '2015-09-04T14:28:40.000Z'
          }
        )
      end

      it 'sends a request to update the existing record' do
        save_action
        assert_requested :patch, 'https://api.airtable.com/v0/appnzIqiDdK0Kew4f/Transactions'
      end

      xit 'sets the Month to the correct Month ID' do
        expect { save_action }.to change { fetch_monzo_record(data['id'])['Month'] }.from(nil).to(['recZtH0Ot7PjORaao'])
      end
    end
  end
end
