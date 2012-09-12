# encoding: utf-8
module Oauth2Helper
  require 'net/http'
  require "uri"
  require 'openssl'

  #支付宝
  PAGE_WAY="https://www.alipay.com/cooperate/gateway.do"
  NOTIFY_URL="http://notify.alipay.com/trade/notify_query.do"
  PARTNER_KEY="y8wpddg38lpu0ks66uluaj8506sw7tks"
  PARTNER="2088002153002681"
  SELLER_EMAIL="yesen@yahoo.cn"
  CALLBACK_URL="http://localhost:3001/user/alipays/take_over_return"
  NONSYNCH_URL="http://localhost:3001/user/alipays/over_pay"

  #weibo账号
  WEIBO_ID = 2359288352

  #赶考网官方微博
  TENCENT_WEIBO_NAME = "gankao2011"

  #人人账号
  RENREN_ID = 600942099
 
  #充值vip有效期
  DATE_LONG={:vip=>90,:trail=>7} #试用七天

  #考试类型
  EXAM_TYPES={:forth_level=>1,:sixth_level=>2}

  #vip价格
  SIMULATION_FEE=48
  VIP_TYPE={:good=>1,:donate=>4}   #vip支付类型
  STUDY_DATE = 29

  #新浪微博应用信息 gankao@hotmail.com  comdosoft2011
  SINA_CLIENT_ID = "3987186573"

  #人人应用信息  wangguanhong@hotmail.com  comdo2010
  RENREN_CLIENT_ID = "211598"
  RENREN_API_KEY = "618f1027bc8146b69f2ffaabe299f685"
  RENREN_API_SECRET = "85dc7b1dddbb4f17af4dd95dbafda820"

  #百度网应用信息
  BAIDU_CLIENT_ID = "251809"
  BAIDU_API_KEY = "BrFpUvlWxiWLKmqvSpOuQjML"
  BAIDU_API_SECRET = "pGK4NMDgf3P3Ch2cqXlHWQZVOFq72AXz"

  #qq登录参数
  REQUEST_URL_QQ="https://graph.qq.com/oauth2.0/authorize"
  #请求openId
  REQUEST_OPENID_URL="https://graph.qq.com/oauth2.0/me"
  #请求详参
  APPID="100302997"
  REQUEST_ACCESS_TOKEN={
    :response_type=>"token",
    :client_id=>APPID,
    :redirect_uri=>"#{Constant::SERVER_PATH}/logins/respond_qq",
    :scope=>"get_user_info,add_topic",
    :state=>"1"
  }


  WEIBO_ACCESS_TOKEN={
    :response_type=>"token",
    :client_id=>APPID,
    :redirect_uri=>"#{Constant::SERVER_PATH}/logins/call_back_qq",
    :scope=>"get_user_info,add_topic",
    :state=>"1"
  }

  KANYAN_SHARE_ACCESS_TOKEN={
    :response_type=>"token",
    :client_id=>APPID,
    :redirect_uri=>"#{Constant::SERVER_PATH}/logins/call_back_and_focus_qq",
    :scope=>"get_user_info,add_topic",
    :state=>"1"
  }
  #新浪微博参数
  REQUEST_URL_WEIBO="https://api.weibo.com/oauth2/authorize"
  REQUEST_WEIBO_TOKEN={
    :response_type=>"token",
    :client_id=>"3987186573",
    :redirect_uri=>"#{Constant::SERVER_PATH}/logins/respond_weibo"
  }
  WEIBO_NAME="gankao2011"
  #  WEIBO_ID="2359288352"

  #构造post请求
  def create_post_http(url,route_action,params)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(route_action)
    request.set_form_data(params)
    return JSON http.request(request).body
  end

  
  #构造get请求
  def create_get_http(url,route)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request= Net::HTTP::Get.new(route)
    back_res =http.request(request)
    return JSON back_res.body
  end

  #新浪微博添加关注
  def request_weibo(access_token,code_id,data)
    weibo_url="https://api.weibo.com"
    weibo_route="/2/friendships/show.json?access_token=#{access_token}&source_id=#{code_id}&target_id=#{Oauth2Helper::WEIBO_ID}"
    user_info=create_get_http(weibo_url,weibo_route)
    unless user_info["source"]["following"]
      params={ :access_token=>access_token,:screen_name=>Oauth2Helper::WEIBO_NAME,:uid=>Oauth2Helper::WEIBO_ID}
      action="/2/friendships/create.json"
      add_info=create_post_http(weibo_url,action,params)
      if add_info["following"]
        data="分享信息成功"
      end
    else
      data="分享信息成功"
    end
    return data
  end

  
  #START -------新浪微博API----------
  #
  #新浪微博主方法
  def sina_api(request)
    uri = URI.parse("https://api.weibo.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.request(request).body
  end
  #
  #新浪微博获取用户信息
  def sina_get_user(access_token,uid)
    request = Net::HTTP::Get.new("/2/users/show.json?access_token=#{access_token}&uid=#{uid}")
    response = JSON sina_api(request)
  end
  #
  #新浪微博发送微博
  def sina_send_message(access_token,message)
    request = Net::HTTP::Post.new("/2/statuses/update.json")
    request.set_form_data({"access_token" =>access_token, "status" => message})
    response =JSON sina_api(request)
  end
  #
  #END -------新浪微博API----------


  #START -------人人API----------
  #
  #人人主方法
  def renren_api(request)
    uri = URI.parse("http://api.renren.com")
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(request).body
  end
  #
  #构成人人签名请求
  def renren_sig_request(query)
    str = ""
    query.sort.each{|key,value|str<<"#{key}=#{value}"}
    str<<RENREN_API_SECRET
    sig = Digest::MD5.hexdigest(str)
    query[:sig]=sig
    request = Net::HTTP::Post.new("/restserver.do")
    request.set_form_data(query)
    return request
  end
  #
  #人人获取用户信息
  def renren_get_user(access_token)
    query = {:access_token => access_token,:format => 'JSON',:method => 'xiaonei.users.getInfo',:v => '1.0'}
    request = renren_sig_request(query)
     response = JSON renren_api(request)
  end
  #
  #人人发送新鲜事
  def renren_send_message(access_token,message)
    query = {:access_token => "#{access_token}",:comment=>"#{message}",:format => 'JSON',:method => 'share.share',:type=>"6",:url=>"http://www.gankao.co",:v => '1.0'}
    request = renren_sig_request(query)
    response =JSON renren_api(request)
  end
  #
  #END -------人人API----------


  #START -------开心网API----------
  #
  #开心主方法
  def kaixin_api(request)
    uri = URI.parse("https://api.kaixin001.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.request(request).body
  end
  #
  #开心获取accesstoken
  def kaixin_accesstoken(code)
    request = Net::HTTP::Get.new("/oauth2/access_token?grant_type=authorization_code&code=#{code}&client_id=#{Constant::KAIXIN_API_KEY}&client_secret=#{Constant::KAIXIN_API_SECRET}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_kaixin")
    response = JSON kaixin_api(request)
  end
  #
  #开心获取用户信息
  def kaixin_get_user(access_token)
    request = Net::HTTP::Get.new("/users/me.json?access_token=#{access_token}")
    response = JSON kaixin_api(request)
  end
  #
  #END -------开心网API----------


  #START -------百度API----------
  #
  #百度主方法
  def baidu_api(request)
    uri = URI.parse("https://openapi.baidu.com")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.request(request).body
  end
  #
  #百度获取accesstoken
  def baidu_accesstoken(code)
    request = Net::HTTP::Get.new("/oauth/2.0/token?grant_type=authorization_code&code=#{code}&client_id=#{Constant::BAIDU_API_KEY}&client_secret=#{Constant::BAIDU_API_SECRET}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_baidu")
    response = JSON baidu_api(request)
  end
  #
  #百度获取用户信息
  def baidu_get_user(access_token)
    request = Net::HTTP::Get.new("/users/me.json?access_token=#{access_token}")
    response = JSON baidu_api(request)
  end
  #
  #
  #百度获取用户信息
  def baidu_get_user(access_token)
    request = Net::HTTP::Get.new("/rest/2.0/passport/users/getLoggedInUser?access_token=#{access_token}")
    response = JSON baidu_api(request)
  end
  #
  #END -------百度API----------


  #qq添加说说
  def send_message_qq(con,openid,access_token,user_id)
    send_parms={:access_token=>access_token,:openid=>openid,:oauth_consumer_key=>Oauth2Helper::APPID,:format=>"json",:third_source=>"3",:con=>con}
    info=create_post_http("https://graph.qq.com","/shuoshuo/add_topic",send_parms)
    if info["data"]["ret"].nil?
      p "qq error_code #{info["data"]["ret"]}"
    else
      p "qq user #{user_id}  send success"
    end
  end

  #开心网添加记录
  def send_message_kaixin(access_token,message)
    url="https://api.kaixin001.com"
    info=create_post_http(url,"/records/add.json",{:access_token=>access_token,:content=>message})
    if info["rid"].nil?
      p "kaixin error code - #{info["error"]}"
    else
      p "kaixin user-record id is  #{info["rid"]}"
    end
  end

  #根据用户类型发送消息
  def send_message(message,user_id)
    begin
      user=User.find(user_id)
      if !user.access_token.nil? and user.access_token!="" and !user.end_time.nil? and user.end_time>Time.now
        message +="赶考网http://www.gankao.co --#{Time.now.strftime(("%Y-%m-%d"))}"
        if user.code_type=="qq" and !user.open_id.nil?
          send_message_qq(message,user.open_id,user.access_token,user_id)
        elsif user.code_type=="renren"
          renren_send_message(user.access_token,message)
        elsif user.code_type=="sina"
          sina_send_message(user.access_token,message)
        elsif user.code_type=="kaixin"
          send_message_kaixin(user.access_token,message)
        end
        #sleep 2
      end
    rescue
    end
  end

  def watch_weibo
    if cookies[:user_id].nil?
      redirect_to "#{Oauth2Helper::REQUEST_URL_WEIBO}?#{Oauth2Helper::REQUEST_WEIBO_TOKEN.map{|k,v|"#{k}=#{v}"}.join("&")}"
    else
      user=User.find(cookies[:user_id].to_i)
      if user.code_type!="sina" || user.access_token.nil? || user.end_time<Time.now
        redirect_to "#{Oauth2Helper::REQUEST_URL_WEIBO}?#{Oauth2Helper::REQUEST_WEIBO_TOKEN.map{|k,v|"#{k}=#{v}"}.join("&")}"
      else
        begin
          flash[:warn]=request_weibo(user.access_token,user.code_id,"关注失败，请登录微博查看")
        rescue
          flash[:warn]="关注失败，请登录微博查看"
        end
        render :inline=>"<div style='width: 200px; height: 32px; margin: 0 auto;' id='text_body'>#{flash[:warn]}</div><script> setTimeout(function(){
                            window.close();}, 3000)</script><% flash[:warn]=nil %>"
      end
    end
  end

  #关注腾讯微博
  def focus_tencent_weibo(access_token,openid)
    send_parms={:oauth_consumer_key=>Oauth2Helper::APPID,:access_token=>access_token,:openid=>openid,
      :format=>"json",:scope=>"all",:oauth_version=>"2.a",:name=>Oauth2Helper::WEIBO_NAME}
    return create_post_http("https://open.t.qq.com","/api/friends/add",send_parms)
  end

  #发送腾讯微博
  def share_tencent_weibo(access_token,openid,message)
    send_parms={:oauth_consumer_key=>Oauth2Helper::APPID,:access_token=>access_token,:openid=>openid,
      :format=>"json",:scope=>"all",:oauth_version=>"2.a",:content=>message}
    return create_post_http("https://open.t.qq.com","/api/t/add",send_parms)
  end

  #更新用户太阳数--分享成功
  def update_user_suns(id,category,type)
    user=User.find(id)
    user_sun=user.suns.where("category_id=#{category} and types=#{type}").find(:all)[0]
    if user_sun  #有分享记录，则不再赠送小太阳
      data="已经奖励您2个小太阳了哦"
    else
      Sun.create(:user_id=>user.id,:category_id=>category,:types=>type,:num=>Sun::TYPE_NUM[:SHARE])
      data="分享信息成功,恭喜您获得2个小太阳"
    end
    return data
  end

  #关注和分享网站,奖励5个小太阳
  def focus_and_share_sun(id,category)
    user_sun=Sun.find_by_sql("select * from suns where user_id=#{id} and category_id=#{category} and types=#{Sun::TYPES[:LOGIN_MORE]}")[0]
    if user_sun
      return "已经奖励您5个小太阳了哦"
    else
      Sun.create(:user_id=>id,:category_id=>category.to_i,:types=>Sun::TYPES[:LOGIN_MORE],:num=>Sun::TYPE_NUM[:LOGIN_MORE])
      return "分享信息成功，恭喜您获得5个小太阳"
    end
  end
end
