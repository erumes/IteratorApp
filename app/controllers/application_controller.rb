class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Add first_name and last_name in Devise users table from UI
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :first_name, :last_name])
  end
end
