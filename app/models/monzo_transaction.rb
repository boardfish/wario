# Cached Monzo transaction
class MonzoTransaction < ApplicationRecord
  include ActiveRecord::Store
  store_accessor :metadata, :amount, :created
  store_accessor :metadata, :id, prefix: :monzo
end
