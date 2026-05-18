# frozen_string_literal: true

class User < ApplicationRecord
  NORTHWESTERN_EMAIL = /\A[^@\s]+@(?:u\.)?northwestern\.edu\z/i.freeze

  has_many :claimed_found_items, class_name: "FoundItem", foreign_key: :claimed_by_user_id,
                                 inverse_of: :claimed_by_user, dependent: :nullify
  has_many :lost_items, inverse_of: :user, dependent: :nullify
  has_many :found_items, inverse_of: :user, dependent: :nullify
  has_many :marketplace_listings, inverse_of: :user, dependent: :nullify
  has_many :rental_items, inverse_of: :user, dependent: :nullify
  has_many :reviews_received, class_name: "Review", foreign_key: :reviewee_id, inverse_of: :reviewee, dependent: :destroy
  has_many :reviews_written, class_name: "Review", foreign_key: :reviewer_id, inverse_of: :reviewer, dependent: :destroy

  attr_reader :password, :password_confirmation
  attr_writer :password_confirmation

  before_validation :normalize_email
  before_validation :normalize_first_name

  validates :email, presence: true
  validates :first_name, length: { maximum: 80 }, allow_blank: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: NORTHWESTERN_EMAIL }
  validates :password, presence: true, on: :create, unless: :omniauth_identity?
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

  # Returns a user or nil (nil when email is missing, not Northwestern, or Google email is unverified).
  def self.from_omniauth(auth)
    return nil unless auth

    info = auth.info
    return nil if auth.dig(:extra, :raw_info, :email_verified) == false

    email = normalize_email(info.email)
    return nil if email.blank? || !email.match?(NORTHWESTERN_EMAIL)

    provider = auth.provider.to_s
    uid = auth.uid.to_s
    return nil if provider.blank? || uid.blank?

    user = find_by(provider: provider, uid: uid)
    user ||= find_by(email: email)

    if user
      fn = first_name_from_omniauth(info, email)
      updates = { provider: provider, uid: uid }
      updates[:first_name] = fn if user.first_name.blank? && fn.present?
      user.update!(updates) unless updates.empty?
      user
    else
      create!(
        email: email,
        first_name: first_name_from_omniauth(info, email),
        provider: provider,
        uid: uid
      )
    end
  rescue ActiveRecord::RecordNotUnique
    find_by(provider: provider, uid: uid) || find_by(email: email)
  end

  def self.first_name_from_omniauth(info, normalized_email)
    raw = info.first_name.presence || info.name.to_s.split(/\s+/, 2).first.presence
    raw = normalized_email.to_s.split("@", 2).first.to_s.tr("._", " ").titleize if raw.blank?
    raw.to_s.strip[0, 80].presence
  end

  def self.ensure_seed_accounts!
    admin_email = ENV.fetch("ADMIN_EMAIL", "admin@u.northwestern.edu").to_s.strip.downcase
    admin_email = "admin@u.northwestern.edu" unless admin_email.match?(NORTHWESTERN_EMAIL)

    [ admin_email, "student@u.northwestern.edu" ].uniq.each do |email|
      next unless email.match?(NORTHWESTERN_EMAIL)

      user = find_or_initialize_by(email: normalize_email(email))
      local = user.email.to_s.split("@", 2).first.to_s
      user.first_name = local.tr("._", " ").titleize[0, 80].presence || "Member"
      user.provider = "google_oauth2"
      user.uid = "dev-seed-#{Digest::SHA256.hexdigest(user.email)[0, 32]}"
      user.save!
    end
  end

  def self.normalize_email(value)
    value.to_s.strip.downcase.presence
  end

  def admin?
    PurplePost::ADMIN_EMAIL.present? && email == PurplePost::ADMIN_EMAIL
  end

  def average_received_rating
    reviews_received.average(:rating)&.to_f&.round(2)
  end

  private

  def omniauth_identity?
    provider.to_s.present? && uid.to_s.present?
  end

  def normalize_email
    self.email = self.class.normalize_email(email)
  end

  def normalize_first_name
    self.first_name = first_name.to_s.strip.presence
  end
end
