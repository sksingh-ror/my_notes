class ApplicationController < ActionController::API
  before_action :authenticate_request

  def authenticate_request
    header = request.headers["Authorization"]
    if header
      token = header.split(" ").last
      begin
        decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
        @current_user = User.find(decoded_token.first["user_id"])
      rescue JWT::DecodeError
        render json: { error: "Invalid token" }, status: :unauthorized
      end
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
