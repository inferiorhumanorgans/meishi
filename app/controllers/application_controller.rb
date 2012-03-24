class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :deny_if_no_users
  before_filter :authenticate_user!

  protected

  ##
  # If no users have been created, we don't have an admin
  # user setup...
  def deny_if_no_users
    if User.count == 0
      render :file => Rails.root.join('public', 'nologin.html'), :status => :forbidden
    end
  end
end