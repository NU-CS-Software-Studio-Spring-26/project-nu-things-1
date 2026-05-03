class User < ApplicationRecord
  NORTHWESTERN_EMAIL = /\A[^@\s]+@(?:u\.)?northwestern\.edu\z/i.freeze

  has_many :claimed_found_items, class_name: "FoundItem", foreign_key: :claimed_by_user_id,
                                 inverse_of: :claimed_by_user, dependent: :nullify

  has_secure_password

  before_validation :normalize_email

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: NORTHWESTERN_EMAIL }
  validates :password, length: { minimum: 8 }, allow_nil: true

  def self.normalize_email(value)
    value.to_s.strip.downcase.presence
  end

  private

  def normalize_email
    self.email = self.class.normalize_email(email)
  end
end
