# frozen_string_literal: true

# Cached Monzo transaction
class MonzoTransaction < ApplicationRecord
  include ActiveRecord::Store
  store_accessor :metadata, :amount, :created
  store_accessor :metadata, :id, prefix: :monzo
  after_save :upsert_into_airtable

  def upsert_into_airtable
    existing_record ? airtable_update(existing_record) : airtable_create
  end

  private

  def existing_record
    transactions_table.all(filter: "{Monzo ID} = '#{monzo_id}'").first
  end

  def airtable_update(record)
    record['Monzo ID'] = monzo_id
    record['Description'] = metadata['description']
    record['Amount'] = amount
    record['Created'] = created
    record['Month'] = [get_airtable_month_total_record(DateTime.parse(created))]
    record.save
  end

  def airtable_create
    transactions_table.create(
      'Monzo ID' => monzo_id,
      'Description' => metadata['description'],
      'Amount' => amount,
      'Created' => created,
      'Month' => [get_airtable_month_total_record(DateTime.parse(created))]
    )
  end

  def get_airtable_month_total_record(date)
    months_table.all(filter: "{Name} = '#{date.strftime('%B %Y')}'").first.id
  end

  def transactions_table
    Airrecord.table(ENV.fetch('AIRTABLE_API_KEY'), ENV.fetch('AIRTABLE_BASE'), 'Transactions')
  end

  def months_table
    Airrecord.table(ENV.fetch('AIRTABLE_API_KEY'), ENV.fetch('AIRTABLE_BASE'), 'Totals')
  end
end
