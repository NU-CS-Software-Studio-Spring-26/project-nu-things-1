# frozen_string_literal: true

class User < ApplicationRecord
  NORTHWESTERN_EMAIL = /\A[^@\s]+@(?:u\.)?northwestern\.edu\z/i.freeze

  has_many :claimed_found_items, class_name: "FoundItem", foreign_key: :claimed_by_user_id,
                                 inverse_of: :claimed_by_user, dependent: :nullify

  attr_reader :password, :password_confirmation
  attr_writer :password_confirmation

  before_validation :normalize_email
  before_validation :normalize_first_name

  validates :email, presence: true
  validates :first_name, length: { maximum: 80 }, allow_blank: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: NORTHWESTERN_EMAIL }
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 8 }, allow_blank: true
  validates :password, confirmation: true, allow_blank: true

  def password=(raw)
    @password = raw
    return if raw.blank?

    self.password_digest = PasswordDigest.encode(raw)
  end

  def password_confirmation=(raw)
    @password_confirmation = raw
  end

  def authenticate(unencrypted_password)
    return false if password_digest.blank?
    return false unless PasswordDigest.verify?(password_digest, unencrypted_password)

    self
  end

  alias authenticate_password authenticate

  # Always stores PBKDF2 digests so sign-in works when the web server cannot load bcrypt.
  def self.ensure_seed_accounts!
    PasswordDigest.with_pbkdf2_passwords! do
      seed_password = ENV.fetch("SEED_USER_PASSWORD", "password")
      admin_email = ENV.fetch("ADMIN_EMAIL", "admin@u.northwestern.edu").to_s.strip.downcase
      admin_email = "admin@u.northwestern.edu" unless admin_email.match?(NORTHWESTERN_EMAIL)

      [ admin_email, "student@u.northwestern.edu" ].uniq.each do |email|
        next unless email.match?(NORTHWESTERN_EMAIL)

        user = find_or_initialize_by(email: normalize_email(email))
        local = user.email.to_s.split("@", 2).first.to_s
        user.first_name = local.tr("._", " ").titleize[0, 80].presence || "Member"
        user.password = seed_password
        user.password_confirmation = seed_password
        user.save!
      end
    end
  end

  def self.normalize_email(value)
    value.to_s.strip.downcase.presence
  end

  def admin?
    ae = Rails.application.config.x.admin_email
    ae.present? && email == ae
  end

  private

  def normalize_email
    self.email = self.class.normalize_email(email)
  end

  def normalize_first_name
    self.first_name = first_name.to_s.strip.presence
  end
end
