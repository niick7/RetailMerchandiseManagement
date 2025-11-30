# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { "Password1!" }
  let(:user) do
    User.create!(
      email: "user@example.com",
      password: password,
      password_confirmation: password
    )
  end

  describe "validations" do
    it "is valid with email and password" do
      expect(user).to be_valid
    end

    it "requires password on create" do
      u = User.new(email: "nopass@example.com")
      expect(u).not_to be_valid
      expect(u.errors[:password]).to be_present
    end

    it "requires matching password confirmation when provided" do
      u = User.new(
        email: "mismatch@example.com",
        password: "Password1!",
        password_confirmation: "OtherPassword!"
      )

      expect(u).not_to be_valid
      expect(u.errors[:password_confirmation]).to be_present
    end
  end

  describe "scopes" do
    let!(:admin) do
      User.create!(
        email: "admin@example.com",
        password: password,
        password_confirmation: password,
        is_admin: true
      )
    end

    let!(:normal) do
      User.create!(
        email: "normal@example.com",
        password: password,
        password_confirmation: password,
        is_admin: false
      )
    end

    it ".api_users returns only non-admin users" do
      result_ids = User.api_users.pluck(:id)
      expect(result_ids).to include(normal.id)
      expect(result_ids).not_to include(admin.id)
    end

    it ".admin_users returns only admin users" do
      result_ids = User.admin_users.pluck(:id)
      expect(result_ids).to include(admin.id)
      expect(result_ids).not_to include(normal.id)
    end

    it ".search finds users by email case-insensitive" do
      u1 = User.create!(
        email: "Nick.Vo@example.com",
        password: password,
        password_confirmation: password
      )

      u2 = User.create!(
        email: "other@example.com",
        password: password,
        password_confirmation: password
      )

      results = User.search("nick.vo")
      expect(results).to include(u1)
      expect(results).not_to include(u2)
    end

    it ".order_created_at orders newest first" do
      older = User.create!(
        email: "old@example.com",
        password: password,
        password_confirmation: password
      )
      newer = User.create!(
        email: "new@example.com",
        password: password,
        password_confirmation: password
      )

      ordered = User.order_created_at
      expect(ordered.first(2)).to eq([newer, older])
    end
  end

  describe "devise customizations" do
    it "active_for_authentication? is true when active" do
      user.update!(active: true)
      expect(user.active_for_authentication?).to be true
    end

    it "active_for_authentication? is false when inactive" do
      user.update!(active: false)
      expect(user.active_for_authentication?).to be false
    end

    it "inactive_message returns :inactive_account when inactive" do
      user.update!(active: false)
      expect(user.inactive_message).to eq(:inactive_account)
    end
  end

  describe "#decrease_api_quota" do
    let!(:api_user) do
      ApiUser.create!(
        user: user,
        api_quota: 2,
        api_token: nil,
        api_token_expired_at: nil
      )
    end

    it "reduces api_quota by 1 and never below 0" do
      user.decrease_api_quota
      expect(api_user.reload.api_quota).to eq(1)

      3.times { user.decrease_api_quota }
      expect(api_user.reload.api_quota).to eq(0)
    end
  end

  describe "#ensure_api_token!" do
    context "when user is non-admin" do
      let!(:api_user) do
        ApiUser.create!(
          user: user,
          api_quota: 10,
          api_token: nil,
          api_token_expired_at: nil
        )
      end

      it "generates JWT token and expiry" do
        travel_to Time.current do
          user.update!(is_admin: false)

          user.ensure_api_token!
          api_user.reload

          expect(api_user.api_token).to be_present

          expected_exp = 15.minutes.from_now.to_i
          actual_exp   = api_user.api_token_expired_at.to_i

          # allow a small drift
          expect(actual_exp).to be_within(5).of(expected_exp)
        end
      end
    end

    context "when user is admin" do
      let(:admin) do
        User.create!(
          email: "admin2@example.com",
          password: password,
          password_confirmation: password,
          is_admin: true
        )
      end

      let!(:api_user) do
        ApiUser.create!(
          user: admin,
          api_quota: 10,
          api_token: nil,
          api_token_expired_at: nil
        )
      end

      it "does nothing (no token generated)" do
        admin.ensure_api_token!
        api_user.reload

        expect(api_user.api_token).to be_nil
        expect(api_user.api_token_expired_at).to be_nil
      end
    end
  end
end