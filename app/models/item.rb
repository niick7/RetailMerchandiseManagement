class Item < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :item_prices
  has_many :item_upcs

  # Validations
  validates :sku, presence: true,
            uniqueness: { case_sensitive: false }

  # Default queries
  scope :search, -> (term) {
    where("LOWER(sku) LIKE ?", "%#{term.to_s.downcase}%")
  }
  scope :order_created_at, -> { order('created_at DESC') }

  # Customized queries
  def primary_price
    price = self.item_prices.
                 where(primary: true).
                 where("effective_date < ? and end_date > ?", Time.now, Time.now).first

    price ? price.price : nil
  end

  def primary_upc
    upc = self.item_upcs.where(primary: true).first
    upc ? upc.upc_code : nil
  end

  # Customized json response
  def as_json(options = {})
    {
      id: id,
      sku: sku,
      price: primary_price,
      upc: primary_upc,
      active: active,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
