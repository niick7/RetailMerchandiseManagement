class Api::ApiController < ActionController::API
  include Pagy::Method
  before_action :authenticate_api_user!

  attr_reader :current_user

  private

  def authenticate_api_user!
    header = request.headers['Authorization']

    return render json: { error: 'Token is missing' }, status: :unauthorized if header.blank?

    token = header.split(' ').last

    begin
      decoded = JWT.decode(
        token,
        jwt_secret,
        true,
        { algorithm: 'HS256' }
      )

      payload = decoded.first
      @current_user = User.find(payload['sub'])

      unless @current_user.active?
        return render_unauthorized(I18n.t("devise.failure.inactive_account"))
      end

      if @current_user.api_user.api_quota <= 0
        return render_unauthorized("API quota exceeded")
      end

      @current_user.decrease_api_quota
    rescue JWT::ExpiredSignature
      render json: { error: 'Token was expired' }, status: :unauthorized
    rescue
      render json: { error: 'Token was invalid' }, status: :unauthorized
    end
  end

  private

  def jwt_secret
    Rails.application.credentials.api_jwt_secret || Rails.application.credentials.secret_key_base
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end
end
