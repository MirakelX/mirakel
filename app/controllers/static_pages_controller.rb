class StaticPagesController < ApplicationController
  def home
    redirect_to list_path "all" if current_user
  end
  def thanks
  end
end
