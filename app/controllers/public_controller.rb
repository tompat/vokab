class PublicController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    redirect_to landing_items_path if user_signed_in?

    @page_title       = 'Never forget your vocabulary again'
    @page_description = 'Use Vokab to memorize faster and longer your new vocabulary. Enjoy, it is 100% free :)'
  end
end
