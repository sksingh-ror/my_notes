class Api::V1::App::UsersController < ApplicationController
  before_action :authenticate_request
  before_action :set_user, only: [ :show, :update, :destroy ]

  def index
    users = User.all
    render json: users
  end

  def show
    render json: @user
  end

  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    render json: { message: "User deleted successfully" }
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
