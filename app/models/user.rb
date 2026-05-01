class User < ApplicationRecord
  NORTHWESTERN_EMAIL = /\A[^@\s]+@(?:u\.)?northwestern\.edu\z/i.freeze

  has_many :login_tokens, dependent: :destroy
  has_many :claims, dependent: :destroy

  validates :email, presence: true
  validates :email, format: { with: NORTHWESTERN_EMAIL }
end
