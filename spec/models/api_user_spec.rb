# spec/models/api_user_spec.rb
require "rails_helper"

RSpec.describe ApiUser, type: :model do
  let(:password) { "Password1!" }
  let(:user) do
    User.create!(
      email: "api-owner@example.com",
      password: password,
      password_confirmation: password
    )
  end

  it "belongs to user" do
    api_user = ApiUser.create!(user: user)
    expect(api_user.user).to eq(user)
  end

  it "defaults api_quota to 0" do
    api_user = ApiUser.create!(user: user)
    expect(api_user.api_quota).to eq(0)
  end
end