class StaticPagesController < ApplicationController
  def home
    respond_to do |format|
      format.html { redirect_to list_path "all" if current_user }
      format.json { render json: 
        { api_version: APP_CONFIG['api_version'],
          hello_text: APP_CONFIG['hello_text'] }
      }
    end
  end
  def thanks
  end
end
