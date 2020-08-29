require 'rails_helper'

RSpec.describe MonzoTransaction, type: :model do
  store_accessor :metadata, :amount, :created
  store_accessor :metadata, :id, prefix: :monzo
end
