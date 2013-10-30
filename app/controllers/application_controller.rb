class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  before_filter :after_token_authentication

  def after_token_authentication
    if params[:authentication_key].present?
      @user = User.find_by_authentication_token(params[:authentication_key]) 
      sign_in @user if @user 
    end
  end

  def after_sign_in_path_for(resource)
    if !current_user.name.nil? && current_user.name.length>0
      taskdconfig_path
    else
      lists_path
    end
  end
end
