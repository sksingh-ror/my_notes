class Api::V1::App::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [ :register, :login ]

  SECRET_KEY = Rails.application.secret_key_base

  def register
    user = User.new(user_params)
    if user.save
      token = JWT.encode({ user_id: user.id }, SECRET_KEY)
      render json: { token: token, message: "User created successfully" }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      token = JWT.encode({ user_id: user.id }, SECRET_KEY)
      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
