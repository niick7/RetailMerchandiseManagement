class Admin::ImportItemPricesController < Admin::AdminController
  def index
    @pagy, @batches = pagy(
      ImportBatch.item_prices.order(created_at: :desc),
      items: 20
    )
  end

  def create
    file = params[:file]
    if file.blank?
      redirect_to admin_import_item_prices_path, alert: "Please choose a CSV file." and return
    end

    timestamp = Time.zone.now.strftime("%Y%m%d%H%M%S")
    tmp_path  = Rails.root.join("tmp", "import_item_prices_#{timestamp}_#{SecureRandom.hex(4)}.csv")
    FileUtils.cp(file.path, tmp_path)

    batch = ImportBatch.create(
      user: current_user,
      import_type: ImportBatch::IMPORT_TYPES[:item_price],
      original_filename: file.original_filename,
      status: ImportBatch::STATUSES[:queued]
    )

    jid = ::ImportItemPricesWorker.perform_async(batch.id, tmp_path.to_s)
    batch.update(sidekiq_jid: jid)

    redirect_to admin_import_item_prices_path,
                notice: "Import job has been queued. Batch #{batch.id}."
  end
end