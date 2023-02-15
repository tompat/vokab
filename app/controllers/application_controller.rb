class ApplicationController < ActionController::Base
  before_action :redirect_root_domain
  before_action :authenticate_user!
  before_action :set_variables

  def set_variables
    return if current_user.nil?
    return if current_user.items.empty?

    @pending_count = current_user.items.pending.count
  end

  private

  def redirect_root_domain
    return unless request.host === 'vokab.io'
    redirect_to("#{request.protocol}www.vokab.io#{request.fullpath}", status: 301)
  end

  def after_sign_in_path_for(resource)
    next_items_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end