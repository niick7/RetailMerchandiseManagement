class ImportBatch < ApplicationRecord
  belongs_to :user

  IMPORT_TYPES = {
    item: 'item',
    item_price: 'item_price',
    item_upc: 'item_upc'
  }.freeze
    
  STATUSES = {
    queued: 'queued',
    running: 'running',
    finished: 'finished',
    failed: 'failed'
  }.freeze

  # Scope
  scope :items,       -> { where(import_type: IMPORT_TYPES[:item]) }
  scope :item_prices, -> { where(import_type: IMPORT_TYPES[:item_price]) }
  scope :item_upcs,   -> { where(import_type: IMPORT_TYPES[:item_upc]) }

  validates :status, inclusion: { in: STATUSES.values }
  validates :import_type, presence: true

  def queued?   = status == STATUSES[:queued]
  def running?  = status == STATUSES[:running]
  def finished? = status == STATUSES[:finished]
  def failed?   = status == STATUSES[:failed]
end