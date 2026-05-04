# frozen_string_literal: true

# Password storage that prefers bcrypt (Rails default) when available, and falls back to
# PBKDF2-SHA256 when bcrypt cannot be loaded (common on broken Windows native-toolchain setups).
module PasswordDigest
  ITERATIONS = 100_000
  PBKDF2_SCHEME = "pbkdf2"

  module_function

  # Use during db:seed / dev bootstrap so digests are PBKDF2 even if bcrypt loads in that process.
  # Otherwise seeds can write bcrypt hashes and sign-in fails in a server where bcrypt cannot load.
  def with_pbkdf2_passwords!
    prev = Thread.current[:nu_password_digest_force_pbkdf2]
    Thread.current[:nu_password_digest_force_pbkdf2] = true
    yield
  ensure
    Thread.current[:nu_password_digest_force_pbkdf2] = prev
  end

  def force_pbkdf2?
    Thread.current[:nu_password_digest_force_pbkdf2]
  end

  def encode(plain_password)
    if force_pbkdf2? || !bcrypt_available?
      encode_pbkdf2(plain_password)
    else
      BCrypt::Password.create(plain_password, cost: bcrypt_cost).to_s
    end
  end

  def encode_pbkdf2(plain_password)
    salt = SecureRandom.random_bytes(16)
    key = derive_pbkdf2(plain_password, salt, ITERATIONS)
    "#{PBKDF2_SCHEME}:#{ITERATIONS}:#{Base64.strict_encode64(salt)}:#{Base64.strict_encode64(key)}"
  end

  def verify?(digest, plain_password)
    return false if digest.blank? || plain_password.blank?

    if digest.start_with?("$2a$", "$2b$", "$2y$")
      verify_bcrypt(digest, plain_password)
    elsif digest.start_with?("#{PBKDF2_SCHEME}:")
      verify_pbkdf2(digest, plain_password)
    else
      false
    end
  end

  def verify_bcrypt(digest, plain_password)
    require "bcrypt"
    BCrypt::Password.new(digest).is_password?(plain_password)
  rescue LoadError => e
    if defined?(Rails) && Rails.logger
      Rails.logger.warn(
        "bcrypt could not be loaded (#{e.message}); cannot verify a bcrypt password_digest. " \
        "Run `bin/rails db:seed` to re-hash dev users with PBKDF2, or fix the bcrypt gem (bundle install)."
      )
    end
    false
  end

  def bcrypt_available?
    return @bcrypt_available if defined?(@bcrypt_available)

    @bcrypt_available = begin
      require "bcrypt"
      true
    rescue LoadError
      false
    end
  end

  def bcrypt_cost
    return BCrypt::Engine::MIN_COST unless defined?(Rails)

    Rails.env.test? ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
  end

  def derive_pbkdf2(plain_password, salt, iterations)
    OpenSSL::KDF.pbkdf2_hmac(
      plain_password,
      salt: salt,
      iterations: iterations,
      length: 32,
      hash: "SHA256"
    )
  end

  def verify_pbkdf2(digest, plain_password)
    _scheme, iter_s, salt_b64, key_b64 = digest.split(":", 4)
    return false unless _scheme == PBKDF2_SCHEME

    iterations = iter_s.to_i
    salt = Base64.strict_decode64(salt_b64)
    expected = Base64.strict_decode64(key_b64)
    candidate = derive_pbkdf2(plain_password, salt, iterations)
    ActiveSupport::SecurityUtils.secure_compare(expected, candidate)
  rescue ArgumentError, OpenSSL::OpenSSLError
    false
  end
end
