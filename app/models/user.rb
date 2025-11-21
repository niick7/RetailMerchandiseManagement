class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :timeoutable
  has_one :api_user, dependent: :destroy
  has_many :items

  # Used for Nested Form
  accepts_nested_attributes_for :api_user, update_only: true, allow_destroy: true

  # Validations
  validates :password, presence: true, on: :create
  validates :password, confirmation: true, allow_blank: true

  # Scope
  scope :api_users, -> { where(is_admin: false) }
  scope :admin_users, -> { where(is_admin: true) }
  scope :search, -> (term) {
    where("LOWER(email) LIKE ?", "%#{term.to_s.downcase}%")
  }
  scope :order_created_at, -> { order('created_at DESC') }

  ### Devise Gem Customization ###
  # Prevent sign in if user is inactive
  def active_for_authentication?
    super && active?
  end

  # User inactive message when logging.
  def inactive_message
    return super if active?

    :inactive_account
  end
  ### Devise Gem Customization ###

  def decrease_api_quota
    quota = [api_user.api_quota - 1, 0].max
    api_user.update_column(:api_quota, quota)
  end

  def ensure_api_token!
    return if is_admin?

    generate_api_jwt!
  end

  private

  def generate_api_jwt!
    exp = 15.minutes.from_now.to_i

    payload = {
      sub: id,          # subject: user id
      email: email,     # optional
      exp: exp,         # expiry (Unix timestamp)
      jti: SecureRandom.uuid # unique id cho token
    }

    token = JWT.encode(payload, jwt_secret, 'HS256')

    api_user.update!(
      api_token: token,
      api_token_expired_at: Time.at(exp)
    )
  end

  def jwt_secret
    Rails.application.credentials.api_jwt_secret || Rails.application.credentials.secret_key_base
  end
end
