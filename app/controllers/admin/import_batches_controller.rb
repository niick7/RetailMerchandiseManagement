class Admin::ImportBatchesController < Admin::AdminController
  def download_failed
    batch = ImportBatch.find(params[:id])

    if batch.failed_file_path.blank? || !File.exist?(batch.failed_file_path)
      redirect_to admin_import_items_path, alert: "Failed file not found." and return
    end

    send_file batch.failed_file_path,
              filename: batch.failed_file_path.split('/').last,
              type: "text/csv",
              disposition: "attachment"
  end
end