#encoding: utf-8
class LoginsController < ApplicationController

  def  renren_like
    redirect_to "http://widget.renren.com/dialog/friends?target_id=#{Constant::RENREN_ID}&app_id=163813&redirect_uri=#{Constant::SERVER_PATH}"
  end

  #退出
  def logout
    cookies.delete(:user_id)
    cookies.delete(:user_name)
    cookies.delete(:user_role)
    redirect_to root_path
  end

  #查看是否充值成功
  def charge_vip
    cookies.delete(:user_role)
    user_role?(cookies[:user_id])
    category_id = params[:category].nil? ? 2 : params[:category]
    redirect_to "/"
  end

  def request_qq
    redirect_to "#{Oauth2Helper::REQUEST_URL_QQ}?#{Oauth2Helper::REQUEST_ACCESS_TOKEN.map{|k,v|"#{k}=#{v}"}.join("&")}"
  end

#  def respond_qq
#    render :layout=>"oauth"
#  end

  def manage_qq
    begin
      meters=params[:access_token].split("&")
      access_token=meters[0].split("=")[1]
      expires_in=meters[1].split("=")[1].to_i
      openid=params[:open_id]
      @user= User.find_by_open_id(openid)
      if @user.nil?
        user_url="https://graph.qq.com"
        user_route="/user/get_user_info?access_token=#{access_token}&oauth_consumer_key=#{Oauth2Helper::APPID}&openid=#{openid}"
        user_info=create_get_http(user_url,user_route)
        user_info["nickname"]="qq用户" if user_info["nickname"].nil?||user_info["nickname"]==""
        @user=User.create(:code_type=>'qq',:name=>user_info["nickname"], :username=>user_info["nickname"],
          :open_id=>openid , :access_token=>access_token, :end_time=>Time.now+expires_in.seconds, :from => User::U_FROM[:WEB])
#        cookies[:first] = {:value => "1", :path => "/", :secure  => false}
      else
        ActionLog.login_log(@user.id)
        if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
          @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+expires_in.seconds)
        end
      end
      cookies[:user_id] ={:value =>@user.id, :path => "/", :secure  => false}
      cookies[:user_name] ={:value =>@user.username, :path => "/", :secure  => false}
      user_role?(cookies[:user_id])
      data=true
    rescue
      data=false
    end
    respond_to do |format|
      format.json {
        render :json=>data
      }
    end
  end

  def request_sina
    redirect_to "https://api.weibo.com/oauth2/authorize?client_id=#{Oauth2Helper::SINA_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_sina&response_type=token"
  end

  def respond_sina
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        #发送微博
        access_token=params[:access_token]
        uid=params[:uid]
        expires_in=params[:expires_in].to_i
        response = sina_get_user(access_token,uid)
        @user=User.find_by_code_id_and_code_type("#{response["id"]}","sina")
        if @user.nil?
          @user=User.create(:code_id=>"#{response["id"]}", :code_type=>'sina',
            :name=>response["screen_name"], :username=>response["screen_name"], :access_token=>access_token,
            :end_time=>Time.now+expires_in.seconds, :from => User::U_FROM[:WEB])
#          cookies[:first] = {:value => "1", :path => "/", :secure  => false}
        else
          ActionLog.login_log(@user.id)
          if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
            @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+expires_in.seconds)
          end
        end
        cookies[:user_name] = {:value =>@user.username, :path => "/", :secure  => false}
        cookies[:user_id] = {:value =>@user.id, :path => "/", :secure  => false}
        user_role?(cookies[:user_id])
        render :inline => "<script>var url = (window.opener.location.href.split('?last_url=')[1]==null)? '/' : window.opener.location.href.split('?last_url=')[1] ;window.opener.location.href=url;window.close();</script>"
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end

#  def watch_weibo
#    if cookies[:user_id].nil?
#      redirect_to "#{Oauth2Helper::REQUEST_URL_WEIBO}?#{Oauth2Helper::REQUEST_WEIBO_TOKEN.map{|k,v|"#{k}=#{v}"}.join("&")}"
#    else
#      user=User.find(cookies[:user_id].to_i)
#      if user.code_type!="sina" || user.access_token.nil? || user.end_time<Time.now
#        redirect_to "#{Oauth2Helper::REQUEST_URL_WEIBO}?#{Oauth2Helper::REQUEST_WEIBO_TOKEN.map{|k,v|"#{k}=#{v}"}.join("&")}"
#      else
#        begin
#          flash[:warn]=request_weibo(user.access_token,user.code_id,"关注失败，请登录微博查看")
#        rescue
#          flash[:warn]="关注失败，请登录微博查看"
#        end
#        render :inline => "<div style='width: 200px; height: 32px; margin: 0 auto;' id='text_body'>#{flash[:warn]}</div><script> setTimeout(function(){
#                            window.close();}, 3000)</script><% flash[:warn]=nil %>#"
#      end
#    end
#  end

#  def respond_weibo
#    render :layout=>"oauth"
#  end
#
#  def add_watch_weibo
#    layout "oauth"
#    data="关注失败，请登录微博查看"
#    begin
#      meters={}
#      params[:access_token].split("&").each do |parm|
#        parms=parm.split("=")
#        parms.each {meters[parms[0]]=parms[1]}
#      end
#      data=request_weibo(meters["access_token"],meters["uid"],data)
#    rescue
#    end
#    respond_to do |format|
#      format.json {
#        render :json=>{:data=>data}, :layout => "ouath"
#      }
#    end
#  end


  def request_renren
    redirect_to "http://graph.renren.com/oauth/authorize?response_type=token&client_id=#{Oauth2Helper::RENREN_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_renren"
  end

  def respond_renren
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        access_token=params[:access_token]
        expires_in=params[:expires_in].to_i
        response = renren_get_user(access_token)[0]
        unless response["uid"]
          redirect_to "/"
          return false
        end
        @user=User.find_by_code_id_and_code_type("#{response["uid"]}","renren")
        if @user.nil?
          @user=User.create(:code_id=>response["uid"],:code_type=>'renren',:name=>response["name"], :username=>response["name"],
            :access_token=>access_token, :end_time=>Time.now+expires_in.seconds, :from => User::U_FROM[:WEB])
#          cookies[:first] = {:value => "1", :path => "/", :secure  => false}
        else
          ActionLog.login_log(@user.id)
          if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
            @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+expires_in.seconds)
          end
        end
        cookies[:user_name] ={:value =>@user.username, :path => "/", :secure  => false}
        cookies[:user_id] ={:value =>@user.id, :path => "/", :secure  => false}
        user_role?(cookies[:user_id])
        render :inline => "<script>var url = (window.opener.location.href.split('?last_url=')[1]==null)? '/' : window.opener.location.href.split('?last_url=')[1] ;window.opener.location.href=url;window.close();</script>"
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end

  def request_baidu
    redirect_to "https://openapi.baidu.com/oauth/2.0/authorize?response_type=code&client_id=#{Oauth2Helper::BAIDU_API_KEY}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_baidu"
  end

  def respond_baidu
    begin
      oauth2 = baidu_accesstoken(params[:code])
      access_token = oauth2["access_token"]
      expires_in = oauth2["expires_in"].to_i
      response = baidu_get_user(access_token)
      unless response["uid"]
        redirect_to "/"
        return false
      end
      @user=User.find_by_code_id_and_code_type("#{response["uid"]}","baidu")
      if @user.nil?
        @user=User.create(:code_id=>response["uid"],:code_type=>'baidu',:name=>response["uname"],
          :username=>response["uname"], :access_token=>access_token, :end_time=>Time.now+expires_in.seconds, :from => User::U_FROM[:WEB])
#        cookies[:first] = {:value => "1", :path => "/", :secure  => false}
      else
        ActionLog.login_log(@user.id)
        if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
          @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+expires_in.seconds)
        end
      end
      cookies[:user_name] ={:value =>@user.username, :path => "/", :secure  => false}
      cookies[:user_id] ={:value =>@user.id, :path => "/", :secure  => false}
      cookies.delete(:user_role)
      user_role?(cookies[:user_id])
      render :inline => "<script>var url = (window.opener.location.href.split('?last_url=')[1]==null)? '/' : window.opener.location.href.split('?last_url=')[1] ;window.opener.location.href=url;window.close();</script>"
    rescue
      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    end
  end

end
