class Users::SessionsController < Devise::SessionsController
  layout 'auth'

  def create
    super do |user|
      user.ensure_api_token!
    end
  end
end