class LoginToken < ApplicationRecord
  belongs_to :user

  validates :expires_at, presence: true

  def used?
    used_at.present?
  end

  def expired?
    expires_at <= Time.current
  end
end

