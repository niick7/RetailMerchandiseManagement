class ItemUpc < ApplicationRecord
  # Associations
  belongs_to :item

  # Validation
  validates :upc_code, presence: true
  validates :upc_code, uniqueness: { case_sensitive: false, message: "already exists" }
  validates :upc_code, length: { minimum: 8, message: "is too short" }

  before_save :ensure_single_primary, if: :primary?

  private

  def ensure_single_primary
    ItemUpc.where(item_id: item_id)
           .where.not(id: id)
           .update_all(primary: false)
  end
end
