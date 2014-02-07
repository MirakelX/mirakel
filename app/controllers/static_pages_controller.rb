require 'rqrcode'
class StaticPagesController < ApplicationController
  def home
    respond_to do |format|
      format.html do
        redirect_to list_path "all" if current_user && current_user.name==""
        redirect_to taskdconfig if current_user && current_user.name!=""
      end
      format.json { render json: 
        { api_version: APP_CONFIG['api_version'],
          hello_text: APP_CONFIG['hello_text'] }
      }
    end
  end
  def thanks
  end
  def taskdconfig
    @user=current_user
    @user=User.find_by_authentication_token(params[:key]) if params[:key]
    if @user.nil?
      render :status => :forbidden, :text => "Forbidden fruit ;)"
      return
    end
    puts "*"*50
    file=File.read("data/#{@user.name}.#{@user.org}.taskdconfig")
    @path=url_for(controller: "staticPages", action:"taskdconfig", key: @user.authentication_token, dl: true)
    @tw = {
      server: "",
      cert: "",
      credentials: "",
      ca: "",
      key: ""
    }
    user=""
    org=""
    key=""
    cert=false
    ca=false
    key=false
    for line in file.lines
      if ca==true
        @tw[:ca]+=line
        ca=false if line.start_with? "-----END CERTIFICATE-----"
      elsif cert == true
        @tw[:cert]+=line
        cert=false if line.start_with? "-----END CERTIFICATE-----"
      elsif key == true
        @tw[:key]+=line
        key=false if line.start_with? "-----END"
      else 
        user=line.sub("username:","").strip        if line.start_with? "username"
        org=line.sub("org:","").strip              if line.start_with? "org"
        user_key=line.sub("user key:","").strip    if line.start_with? "user key"
        @tw[:server]=line.sub("server:","").strip  if line.start_with? "server"
        cert=true                                  if line.start_with? "Client.cert"
        ca=true                                    if line.start_with? "ca.cert"
        key=true                                   if line.start_with? "Client.key"
      end

    end
    @tw[:ca]=@tw[:ca].strip
    @tw[:cert]=@tw[:cert].strip
    @tw[:credentials]="#{org}/#{user}/#{user_key}"
    @qr = RQRCode::QRCode.new(@path, level: :l)

    if params[:dl]
      response.headers['Content-Disposition'] = 'attachment; filename=mirakel.taskdconfig'
      response.headers['Content-Type']='application/force-download'
      render(:text => file)
      return
    elsif params[:sh]
      response.headers['Content-Disposition'] = 'attachment; filename=taskd_setup.sh'
      response.headers['Content-Type']='application/force-download'
      render(:text => """#!/bin/bash
echo \"yes\" | task config taskd.server #{@tw[:server]}
echo \"yes\" | task config taskd.credentials #{@tw[:credentials]}
echo \"#{@tw[:cert]}\" > ~/.task/client.pem
echo \"yes\" | task config taskd.certificate ~/.task/client.pem
echo \"#{@tw[:ca]}\" > ~/.task/ca.pem
echo \"yes\" | task config taskd.ca ~/.task/ca.pem
echo \"#{@tw[:key]}\" > ~/.task/client.key.pem
echo \"yes\" | task config taskd.key ~/.task/client.key.pem
task sync

echo \"Have fun. If you like Mirakel, give us some feedback ;)\"
      """)
      return
    end

    respond_to do |format|
      format.html do
        render layout: "taskd"
      end
    end
  end
end
