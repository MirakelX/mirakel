class TokensController < ApplicationController
  skip_before_filter :verify_authenticity_token
    respond_to :json
    def create
      email = params[:email]
      password = params[:password]
      puts "beginn"
      puts password
      puts "end"
      puts params
      if request.format != :json
        render :status=>406, :json=>{:message=>"The request must be json"}
        return
       end

    if email.nil? or password.nil?
       render :status=>400,
              :json=>{:message=>"The request must contain the user email and password."}
       return
    end

    @user=User.find_by_email(email.downcase)

    if @user.nil?
      logger.info("User #{email} failed signin, user cannot be found.")
      render :status=>401, :json=>{:message=>"Invalid email or passoword."}
      return
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!
    

    if not @user.valid_password?(password)
      logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
      render :status=>401, :json=>{:message=>"Invalid email or password."}
    else
      #o=[('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
      #s= (0...50).map{ o[rand(o.length)] }.join
      @user.reset_authentication_token!
      render :status=>200, :json=>{:token=>@user.authentication_token}
    end
  end

  def destroy
    @user=User.find_by_authentication_token(params[:id])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>404, :json=>{:message=>"Invalid token."}
    else
      @user.reset_authentication_token!
      #@user.expire_auth_token_on_timeout
      render :status=>200, :json=>{:message=>"Mark Token Invalid"}#:token=>params[:id]}
    end
  end

end
