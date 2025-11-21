class ImportItemUpcsWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default

  def perform(batch_id, file_path)
    batch = ImportBatch.find(batch_id)

    batch.update(
      status: ImportBatch::STATUSES[:running],
      started_at: Time.current
    )

    user = batch.user
    file = File.open(file_path)

    result = ::Items::ImportItemUpcService.call(file: file, user: user)

    failed_path = nil
    if result.failed_rows_csv.present?
      timestamp   = Time.zone.now.strftime("%Y%m%d%H%M%S")
      failed_path = Rails.root.join("tmp", "failed_item_prices_batch_#{batch.id}_#{timestamp}.csv")
      File.write(failed_path, result.failed_rows_csv)
    end

    total = result.success_count.to_i + result.error_count.to_i

    batch.update!(
      status:        result.error_count.to_i > 0 ? ImportBatch::STATUSES[:failed] : ImportBatch::STATUSES[:finished],
      total_rows:    total,
      success_count: result.success_count,
      error_count:   result.error_count,
      failed_file_path: failed_path&.to_s,
      error_messages: (result.errors.presence && result.errors.join("\n")),
      finished_at:   Time.current
    )
  rescue => e
    batch.update!(
      status: ImportBatch::STATUSES[:failed],
      error_messages: [batch.error_messages, "Worker error: #{e.message}"].compact.join("\n"),
      finished_at: Time.current
    )
    raise e
  ensure
    file&.close
  end
end