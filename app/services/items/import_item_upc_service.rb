require "csv"

module Items
  class ImportItemUpcService
    HEADER = ['SKU', 'Active', 'UPC', 'UPC Primary'].freeze
    Result = Struct.new(:success_count, :error_count, :errors, :failed_rows_csv, keyword_init: true)

    def self.call(file:, user:)
      new(file, user).call
    end

    def initialize(file, user)
      @file = file
      @user = user
    end

    def call
      success_count = 0
      errors = []
      failed_rows = []
      boolean_type = ActiveModel::Type::Boolean.new

      csv = CSV.read(@file.path, headers: true)
      headers = csv.headers.map(&:strip)
      if headers != HEADER
        return Result.new(
          success_count: 0,
          error_count: 1,
          errors: ["Template header is invalid. Expected: #{HEADER.join(', ')}"],
          failed_rows_csv: nil
        )
      end

      line_number = 1
      csv.each do |row|
        line_number += 1

        sku           = row["SKU"]&.strip
        active_raw    = row['Active'].present? ? true : false
        upc_raw       = row["UPC"]&.strip
        upc_primary_raw = row["UPC Primary"].present? ? true : false

        # Import Item
        item = Item.find_or_initialize_by(sku: sku)
        item.user = @user
        item.active = row['Active'].present? ? true : false
        unless item.save
          errors << "Line #{line_number}: #{item.errors.full_messages.to_sentence}"
          failed_rows << row.to_h.merge("error" => item.errors.full_messages.join(", "))
          next
        end

        # Import UPC
        if upc_raw.present?
          item_upc = item.item_upcs.new(
            upc_code: upc_raw,
            primary: upc_primary_raw
          )
          unless item_upc.save
            errors << "Line #{line_number}: #{item_upc.errors.full_messages.to_sentence}"
            failed_rows << row.to_h.merge("error" => item_upc.errors.full_messages.join(", "))
            next
          end
        end

        success_count += 1
      end

      failed_rows_csv = generate_failed_rows_csv(headers, failed_rows)

      Result.new(
        success_count: success_count,
        error_count: errors.size,
        errors: errors,
        failed_rows_csv: failed_rows_csv
      )
    end

    private

    def generate_failed_rows_csv(headers, rows)
      return nil if rows.empty?

      CSV.generate do |csv|
        csv << (headers + ["error"])
        rows.each { |r| csv << r.values_at(*headers, "error") }
      end
    end
  end
end