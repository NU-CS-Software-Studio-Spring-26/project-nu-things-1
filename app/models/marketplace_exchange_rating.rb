# frozen_string_literal: true

class MarketplaceExchangeRating < ApplicationRecord
  include ExchangeRatingReasons

  belongs_to :marketplace_transaction
  belongs_to :rater, class_name: "User"
  belongs_to :ratee, class_name: "User", inverse_of: :received_marketplace_exchange_ratings

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :rating, numericality: { only_integer: true }
  validates :rater_id, uniqueness: { scope: %i[marketplace_transaction_id ratee_id] }

  validate :participants_match_transaction
  validate :transaction_must_be_complete
  validate :cannot_rate_self

  private

  def participants_match_transaction
    return if marketplace_transaction.blank? || rater.blank? || ratee.blank?

    allowed = [ marketplace_transaction.buyer_id, marketplace_transaction.seller_id ]
    unless allowed.include?(rater_id) && allowed.include?(ratee_id)
      errors.add(:base, "Rater and ratee must both belong to this marketplace transaction")
    end
  end

  def transaction_must_be_complete
    return if marketplace_transaction.blank?
    return if marketplace_transaction.complete?

    errors.add(:marketplace_transaction, "must be complete before ratings are submitted")
  end

  def cannot_rate_self
    return if rater_id.blank? || ratee_id.blank?
    errors.add(:ratee, "cannot be the same as the rater") if rater_id == ratee_id
  end
end
