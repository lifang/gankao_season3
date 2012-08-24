#encoding: utf-8
class LoginsController < ApplicationController
  include Oauth2Helper
#  before_filter :get_role, :except=> ["charge_vip"]  #charge_vip需开放请求，避免过滤
  respond_to :html, :xml, :json
  @@m = Mutex.new



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
        render :inline => "<script>var url = (window.opener.location.href.split('?last_url=')[1]==null)? '/' : window.opener.location.href.split('?last_url=')[1] ;window.opener.location.href=url;window.close();</script>"
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end



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
      render :inline => "<script>var url = (window.opener.location.href.split('?last_url=')[1]==null)? '/' : window.opener.location.href.split('?last_url=')[1] ;window.opener.location.href=url;window.close();</script>"
    rescue
      render :inline => "<script>window.opener.location.reload();window.close();</script>"
    end
  end


  #邀请码升级vip
  def accredit_check
    code=InviteCode.first(:conditions=>["code = ? and category_id = ?", params[:info].strip, params[:category]])
    if code.nil?
      data="邀请码不存在"
    else
      if code.user_id
        data="邀请码已被使用"
      else
        data="升级成功"
        order=Order.first(:conditions=>"user_id=#{cookies[:user_id]} and category_id=#{code.category_id} and status=#{Order::STATUS[:NOMAL]}")
        if order.nil?
          Order.create(:user_id=>cookies[:user_id],:category_id=>code.category_id,:pay_type=>Order::PAY_TYPES[:LICENSE],
            :out_trade_no=>"#{cookies[:user_id]}_#{Time.now.strftime("%Y%m%d%H%M%S")}#{Time.now.to_i}",
            :status=>Order::STATUS[:NOMAL],:remark=>"邀请码升级vip",:start_time=>Time.now,:types=>Order::TYPES[:ACCREDIT],
            :end_time=>Time.now+Constant::DATE_LONG.days)
        else
          str = order.end_time.nil? ? "" : "，截止日期是#{order.end_time.strftime("%Y-%m-%d")}"
          data = "您已是vip用户#{str}"
        end
      end
    end
    respond_to do |format|
      format.json {
        render :json=>{:message=>data}
      }
    end
  end

  #检查是否需要充值vip
  def check_vip
    order = Order.first(
      :conditions => "user_id = #{cookies[:user_id]} and category_id = #{params[:category]} and status = #{Order::STATUS[:NOMAL]}")
    end_time = ""
    is_vip = true
    if order
      is_vip = false
      end_time = (order.end_time.nil?) ? "" : order.end_time.strftime("%Y-%m-%d")
    end
    respond_to do |format|
      format.json {
        render :json=>{:vip => is_vip, :time => end_time}
      }
    end
  end #此查询状态status需在过期时被自动作废

  #发送充值请求
  def alipay_exercise
    category = Category.find(params[:category].to_i)
    options ={
      :service=>"create_direct_pay_by_user",
      :notify_url=>Constant::SERVER_PATH+"/logins/alipay_compete",
      :subject=>"会员购买#{category.name}产品",
      :payment_type=>Order::PAY_TYPES[:CHARGE],
      :total_fee=>params[:total_fee]
    }
    out_trade_no="#{cookies[:user_id]}_#{Time.now.strftime("%Y%m%d%H%M%S")}#{Time.now.to_i}_#{params[:category]}"
    options.merge!(:seller_email =>Oauth2Helper::SELLER_EMAIL, :partner =>Oauth2Helper::PARTNER, :_input_charset=>"utf-8", :out_trade_no=>out_trade_no)
    options.merge!(:sign_type => "MD5", :sign =>Digest::MD5.hexdigest(options.sort.map{|k,v|"#{k}=#{v}"}.join("&")+Oauth2Helper::PARTNER_KEY))
    redirect_to "#{Oauth2Helper::PAGE_WAY}?#{options.sort.map{|k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')}"
  end

  #充值异步回调
  def alipay_compete
    out_trade_no=params[:out_trade_no]
    trade_nu =out_trade_no.to_s.split("_")
    order=Order.find(:first, :conditions => ["out_trade_no=?",params[:out_trade_no]])
    if order.nil?
      alipay_notify_url = "#{Oauth2Helper::NOTIFY_URL}?partner=#{Oauth2Helper::PARTNER}&notify_id=#{params[:notify_id]}"
      response_txt =Net::HTTP.get(URI.parse(alipay_notify_url))
      my_params = Hash.new
      request.parameters.each {|key,value|my_params[key.to_s]=value}
      my_params.delete("action")
      my_params.delete("controller")
      my_params.delete("sign")
      my_params.delete("sign_type")
      mysign = Digest::MD5.hexdigest(my_params.sort.map{|k,v|"#{k}=#{v}"}.join("&")+Oauth2Helper::PARTNER_KEY)
      dir = "#{Rails.root}/public/compete"
      Dir.mkdir(dir)  unless File.directory?(dir)
      file_path = dir+"/#{Time.now.strftime("%Y%m%d")}.log"
      if File.exists? file_path
        file = File.open( file_path,"a")
      else
        file = File.new(file_path, "w")
      end
      file.puts "#{Time.now.strftime('%Y%m%d %H:%M:%S')}   #{request.parameters.to_s}\r\n"
      file.close
      if mysign==params[:sign] and response_txt=="true"
        if params[:trade_status]=="WAIT_BUYER_PAY"
          render :text=>"success"
        elsif params[:trade_status]=="TRADE_FINISHED" or params[:trade_status]=="TRADE_SUCCESS"
          @@m.synchronize {
            begin
              Order.transaction do
                order=Order.first(:conditions=>"user_id=#{trade_nu[0]} and category_id=#{trade_nu[2]} and status=#{Order::STATUS[:NOMAL]}")
                if order.nil?
                  Order.create(:user_id=>trade_nu[0],:category_id=>trade_nu[2].to_i,:pay_type=>Order::PAY_TYPES[:CHARGE],
                    :out_trade_no=>"#{params[:out_trade_no]}",:status=>Order::STATUS[:NOMAL],:remark=>"支付宝充值升级vip",
                    :start_time=>Time.now,:end_time=>Time.now+Constant::DATE_LONG.days,:types=>Order::TYPES[:CHARGE])
                end
              end
              render :text=>"success"
            rescue
              render :text=>"success"
            end
          }
        else
          render :text=>"fail" + "<br>"
        end
      else
        redirect_to "/"
      end
    else
      render :text=>"success"
    end
  end

end
