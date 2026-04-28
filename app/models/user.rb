class User < ApplicationRecord
  has_many :login_tokens, dependent: :destroy
  has_many :claims, dependent: :destroy

  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end

