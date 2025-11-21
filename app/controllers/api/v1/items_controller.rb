class Api::V1::ItemsController < Api::ApiController
  def index
    keyword = params[:q].to_s.strip
    @pagy, @records = pagy(Item.search(keyword).order_created_at, jsonapi: true)
    render json: { links: @pagy.urls_hash, data: @records }
  end
end
