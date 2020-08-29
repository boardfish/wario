# frozen_string_literal: true

# Receiver for Monzo webhook
class MonzoHookReceiverController < ApplicationController
  def transaction
    MonzoTransaction.create!(metadata: transaction_params)
  end

  private

  def transaction_params
    params.require(:data).permit(
      :account_id, :amount, :created, :currency, :description, :id, :category, :is_load, :settled,
      merchant: [
        :created, :group_id, :id, :logo, :emoji, :name, :category,
        address: %i[address city country latitude longitude postcode region]
      ]
    )
  end
end
