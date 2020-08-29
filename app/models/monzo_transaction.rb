# Cached Monzo transaction
class MonzoTransaction < ApplicationRecord
  store_accessor :metadata, :id, :amount
end
