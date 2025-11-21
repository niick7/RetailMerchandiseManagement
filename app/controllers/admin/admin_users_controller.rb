class Admin::AdminUsersController < Admin::AdminController
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @keyword = params[:q].to_s.strip
    @pagy, @users = pagy(User.admin_users.search(@keyword).order_created_at)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_admin_users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    filtered_params = user_params
    if filtered_params[:password].blank?
      filtered_params = filtered_params.except(:password, :password_confirmation)
    end

    if @user.update(filtered_params)
      redirect_to admin_admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_admin_users_path, notice: "User deleted successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :is_admin, :active)
  end
end
