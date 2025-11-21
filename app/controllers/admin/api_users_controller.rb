class Admin::ApiUsersController < Admin::AdminController
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @keyword = params[:q].to_s.strip
    @pagy, @users = pagy(User.api_users.search(@keyword).order_created_at)
  end

  def new
    @user = User.new
    @user.build_api_user
  end

  def create
    @user = User.new(user_params)
    @user.build_api_user unless @user.api_user

    if @user.save
      redirect_to admin_api_user_path(@user), notice: "API user created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    @user.build_api_user if @user.api_user.nil?
  end

  def update
    filtered_params = user_params
    if filtered_params[:password].blank?
      filtered_params = filtered_params.except(:password, :password_confirmation)
    end
    @user.build_api_user if @user.api_user.nil?

    if @user.update(filtered_params)
      redirect_to admin_api_user_path(@user), notice: "API user updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.includes(:api_user).find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :is_admin,
      :active,
      api_user_attributes: [
        :id,
        :api_quota
      ]
    )
  end
end
