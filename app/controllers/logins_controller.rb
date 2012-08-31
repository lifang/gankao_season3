#encoding: utf-8
class LoginsController < ApplicationController
  include Oauth2Helper
  layout nil
  before_filter :sign?, :only => ["check_vip", "alipay_exercise", "accredit_check"]
  respond_to :html, :xml, :json
  @@m = Mutex.new



  #退出
  def logout
    cookies.delete(:user_id)
    cookies.delete(:user_name)
    cookies.delete(:user_role)
    redirect_to root_path
  end


  def request_qq
    redirect_to "#{Oauth2Helper::REQUEST_URL_QQ}?#{Oauth2Helper::REQUEST_ACCESS_TOKEN.map{|k,v|"#{k}=#{v}"}.join("&")}"
  end

  def manage_qq
    render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?').replace('manage_qq','respond_qq');</script>"
  end

  def respond_qq
    begin
      access_token=params["access_token"]||params["?access_token"]
      puts "------------------------------"
      puts params[:open_id]
      expires_in=params[:expires_in].to_i
      openid=params[:open_id]
      @user= User.find_by_open_id(openid) if openid
      if @user.nil?
        user_url="https://graph.qq.com"
        user_route="/user/get_user_info?access_token=#{access_token}&oauth_consumer_key=#{Oauth2Helper::APPID}&openid=#{openid}"
        user_info=create_get_http(user_url,user_route)
        user_info["nickname"]="qq用户" if user_info["nickname"].nil?||user_info["nickname"]==""
        @user=User.create(:code_type=>'qq',:name=>user_info["nickname"], :username=>user_info["nickname"],
          :open_id=>openid , :access_token=>access_token, :end_time=>Time.now+expires_in.seconds, :from => User::U_FROM[:WEB])
        Sun.first_login(@user.id)
      else
        if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
          @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+expires_in.seconds)
        end
      end
      user_role?(@user.id)
      cookies[:user_id] ={:value =>@user.id, :path => "/", :secure  => false}
      cookies[:user_name] ={:value =>@user.username, :path => "/", :secure  => false}
    rescue
    end
    render :inline => "<script>window.opener.location.reload;window.close();</script>"
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
          Sun.first_login(@user.id)
        else
          ActionLog.login_log(@user.id)
          if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
            @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+expires_in.seconds)
          end
        end
        user_role?(@user.id)
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
          Sun.first_login(@user.id)
        else
          ActionLog.login_log(@user.id)
          if @user.access_token.nil? || @user.access_token=="" || @user.access_token!=access_token
            @user.update_attributes(:access_token=>access_token,:end_time=>Time.now+expires_in.seconds)
          end
        end
        user_role?(@user.id)
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


  def call_back_sina
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        #发送微博
        access_token=params[:access_token]
        content=cookies[:sharecontent].split('@!')
        ret = sina_send_message(access_token, content[1])
        type=Sun::TYPES[:SINASHARE].to_i
        @return_message = "微博发送失败，请重新尝试" if ret["error_code"]
        if @return_message.nil?
          render :text=>update_user_suns(cookies[:user_id].to_i,content[0].to_i,type)
        else
          render :text=>@return_message
        end
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end

  def call_back_renren
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        #发送微博
        access_token=params[:access_token]
        content=cookies[:sharecontent].split('@!')
        ret = renren_send_message(access_token, content[1])
        type=Sun::TYPES[:RENRENSHARE].to_i
        @return_message = "分享失败，请重新尝试" if ret[:error_code]
        if @return_message.nil?
          render :text=>update_user_suns(cookies[:user_id].to_i,content[0].to_i,type)
        else
          render :text=>@return_message
        end
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end

  def call_back_qq
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        #发送微博
        access_token=params["access_token"]
        openid=params[:open_id]
        content=cookies[:sharecontent].split('@!')
        type=Sun::TYPES[:QQSHARE].to_i
        ret = share_tencent_weibo(access_token,openid,content[1])
        @return_message = "分享失败，请重新尝试" if ret[:errcode].to_i!=0
        if @return_message.nil?
          render :text=>update_user_suns(cookies[:user_id].to_i,content[0].to_i,type)
        else
          render :text=>@return_message
        end
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end


  #发送微博和关注微博
  def call_back_and_focus_sina
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        uid=params[:uid]
        #发送微博
        access_token=params[:access_token]
        content=cookies[:sharecontent].split('@!')
        ret = sina_send_message(access_token, content[1])
        return_message = "微博发送失败，请重新尝试" if ret["error_code"]
        if return_message.nil?
          focus_and_share_sun(cookies[:user_id].to_i,content[0].to_i)
        end

        response = sina_get_user(access_token,uid)
        render :text=>request_weibo(access_token,response["id"],"关注失败，请登录微博查看")
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end
  #关注人人和发送新鲜事
  def call_back_and_focus_renren
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        #发送人人新鲜事
        access_token=params[:access_token]
        content=cookies[:sharecontent].split('@!')
        ret = renren_send_message(access_token, content[1])
        @return_message = "分享失败，请重新尝试" if ret[:error_code]
        if @return_message.nil?
          focus_and_share_sun(cookies[:user_id].to_i,content[0].to_i)
        end
        #加人人好友
        redirect_to "http://widget.renren.com/dialog/friends?target_id=#{Oauth2Helper::RENREN_ID}&app_id=163813&redirect_uri=#{Constant::SERVER_PATH}"
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end

  def call_back_and_focus_qq
    if cookies[:oauth2_url_generate]
      begin
        cookies.delete(:oauth2_url_generate)
        #发送微博
        access_token=params["access_token"]
        open_id=params[:open_id]
        content=cookies[:sharecontent].split('@!')
        info=share_tencent_weibo(access_token,open_id,content[1])
        @return_message="腾讯微博分享失败，请重新尝试" if info["ret"].to_i!=0
        #分享成功
        if @return_message.nil?
          #送5个太阳
          focus_and_share_sun(cookies[:user_id].to_i,content[0].to_i)
        end

        info=focus_tencent_weibo(access_token,open_id)
        @return_message="关注腾讯微博失败" if info["ret"].to_i!=0
        if @return_message.nil?
          render :text=>"关注腾讯微博成功"
        else
          render :text=>@return_message
        end
      rescue
        render :inline => "<script>window.opener.location.reload();window.close();</script>"
      end
    else
      cookies[:oauth2_url_generate]="replace('#','?')"
      render :inline=>"<script type='text/javascript'>window.location.href=window.location.toString().replace('#','?');</script>"
    end
  end


  #发送充值请求
  def alipay_sun
    options ={
      :service=>"create_direct_pay_by_user",
      :notify_url=>Constant::SERVER_PATH+"/logins/sun_compete",
      :subject=>"购买#{params[:total_fee]}个小太阳",
      :payment_type=>Order::PAY_TYPES[:CHARGE],
      :total_fee=>params[:total_fee]
    }
    out_trade_no="#{cookies[:user_id]}_#{Time.now.strftime("%Y%m%d%H%M%S")}#{Time.now.to_i}_#{params[:category]}_#{params[:total_fee]}"
    options.merge!(:seller_email =>Oauth2Helper::SELLER_EMAIL, :partner =>Oauth2Helper::PARTNER, :_input_charset=>"utf-8", :out_trade_no=>out_trade_no)
    options.merge!(:sign_type => "MD5", :sign =>Digest::MD5.hexdigest(options.sort.map{|k,v|"#{k}=#{v}"}.join("&")+Oauth2Helper::PARTNER_KEY))
    redirect_to "#{Oauth2Helper::PAGE_WAY}?#{options.sort.map{|k, v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')}"
  end

  #充值异步回调
  def sun_compete
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
              Sun.transaction do
                Sun.create(:user_id=>trade_nu[0],:category_id=>trade_nu[2].to_i,:types=>Sun::TYPES[:CHARGE],:num=>trade_nu[3].to_i)
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
        render :text=>"fail" + "<br>"
      end
    else
      render :text=>"success"
    end
  end

end
