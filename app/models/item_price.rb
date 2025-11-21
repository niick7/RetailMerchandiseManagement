class ItemPrice < ApplicationRecord
  # Associations
  belongs_to :item

  # Validations
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :effective_date, presence: true
  validates :end_date, presence: true
  validate  :end_date_after_start

  # One item should have exact one primary price
  before_save :ensure_only_one_primary, if: :primary?

  private

  def end_date_after_start
    return if effective_date.blank? || end_date.blank?

    if end_date < effective_date
      errors.add(:end_date, "must be after effective_date")
    end
  end

  def ensure_only_one_primary
    ItemPrice
      .where(item_id: item_id)
      .where.not(id: id)
      .update_all(primary: false)
  end
end
