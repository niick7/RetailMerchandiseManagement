# spec/models/item_spec.rb
require "rails_helper"

RSpec.describe Item, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:password) { "Password1!" }
  let(:user) do
    User.create!(
      email: "owner@example.com",
      password: password,
      password_confirmation: password
    )
  end

  let(:item) do
    Item.create!(
      user: user,
      sku: "SKU-001",
      active: true
    )
  end

  # ===== Validations =====
  describe "validations" do
    it "is valid with sku and user" do
      expect(item).to be_valid
    end

    it "requires sku" do
      bad_item = Item.new(user: user, sku: nil)
      expect(bad_item).not_to be_valid
      expect(bad_item.errors[:sku]).to be_present
    end

    it "enforces case-insensitive uniqueness of sku" do
      Item.create!(user: user, sku: "ABC123")

      dup_item = Item.new(user: user, sku: "abc123")

      expect(dup_item).not_to be_valid
      expect(dup_item.errors[:sku]).to be_present
    end
  end

  # ===== Instance methods: primary_price =====
  describe "#primary_price" do
    let(:item) { Item.create!(user: user, sku: "SKU-PRICE") }

    it "returns the current primary price" do
      travel_to Time.current do
        ItemPrice.create!(
          item: item,
          price: BigDecimal("9.99"),
          effective_date: 1.day.ago,
          end_date: 1.day.from_now,
          primary: true
        )

        expect(item.primary_price).to eq(BigDecimal("9.99"))
      end
    end

    it "ignores non-primary prices" do
      ItemPrice.create!(
        item: item,
        price: BigDecimal("5.00"),
        effective_date: 1.day.ago,
        end_date: 1.day.from_now,
        primary: false
      )

      expect(item.primary_price).to be_nil
    end

    it "ignores prices outside date range" do
      ItemPrice.create!(
        item: item,
        price: BigDecimal("15.00"),
        effective_date: 5.days.ago,
        end_date: 4.days.ago,
        primary: true
      )

      expect(item.primary_price).to be_nil
    end
  end

  # ===== Instance methods: primary_upc =====
  describe "#primary_upc" do
    let(:item) { Item.create!(user: user, sku: "SKU-UPC") }

    it "returns the primary upc code" do
      ItemUpc.create!(item: item, upc_code: "111111111111", primary: false)
      primary = ItemUpc.create!(item: item, upc_code: "999999999999", primary: true)

      expect(item.primary_upc).to eq(primary.upc_code)
    end

    it "returns nil when no primary upc" do
      ItemUpc.create!(item: item, upc_code: "111111111111", primary: false)
      expect(item.primary_upc).to be_nil
    end
  end

  # ===== as_json =====
  describe "#as_json" do
    let(:item) { Item.create!(user: user, sku: "SKU-JSON", active: true) }

    it "returns custom hash with price and upc" do
      travel_to Time.current do
        price = ItemPrice.create!(
          item: item,
          price: BigDecimal("19.99"),
          effective_date: 1.day.ago,
          end_date: 1.day.from_now,
          primary: true
        )
        upc = ItemUpc.create!(
          item: item,
          upc_code: "123456789012",
          primary: true
        )

        json = item.as_json

        expect(json[:id]).to eq(item.id)
        expect(json[:sku]).to eq("SKU-JSON")
        expect(json[:price]).to eq(price.price)
        expect(json[:upc]).to eq(upc.upc_code)
        expect(json[:active]).to eq(true)
        expect(json[:created_at]).to eq(item.created_at)
        expect(json[:updated_at]).to eq(item.updated_at)
      end
    end
  end
end