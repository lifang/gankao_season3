# encoding: utf-8
module Oauth2Helper
  require 'net/http'
  require "uri"
  require 'openssl'
  require 'net/http/post/multipart'

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
  #  RENREN_CLIENT_ID = "211598"
  #  RENREN_API_KEY = "618f1027bc8146b69f2ffaabe299f685"
  #  RENREN_API_SECRET = "85dc7b1dddbb4f17af4dd95dbafda820"
  RENREN_CLIENT_ID = "182012"
  RENREN_API_KEY = "98a6ed88bccc409da12a8abe3ebec3c5"
  RENREN_API_SECRET = "0d19833c0bc34a27a58786c07ef8d9fb"

  #百度网应用信息
  BAIDU_CLIENT_ID = "251809"
  BAIDU_API_KEY = "BrFpUvlWxiWLKmqvSpOuQjML"
  BAIDU_API_SECRET = "pGK4NMDgf3P3Ch2cqXlHWQZVOFq72AXz"

  #qq登录参数
  REQUEST_URL_QQ="https://graph.qq.com/oauth2.0/authorize"
  #请求openId
  REQUEST_OPENID_URL="https://graph.qq.com/oauth2.0/me"
  #请求详参
  APPID="223448"
  REQUEST_ACCESS_TOKEN={
    :response_type=>"token",
    :client_id=>APPID,
    :redirect_uri=>"#{Constant::SERVER_PATH}/logins/respond_qq",
    :scope=>"get_user_info,add_topic,add_pic_t,add_share,add_t",
    :state=>"1"
  }


  WEIBO_ACCESS_TOKEN={
    :response_type=>"token",
    :client_id=>APPID,
    :redirect_uri=>"#{Constant::SERVER_PATH}/logins/call_back_qq",
    :scope=>"get_user_info,add_topic,add_pic_t,add_share,add_t",
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
  WEIBO_NAME="gankao2011"
  #  WEIBO_ID="2359288352"
  REQUEST_URL_WEIBO="https://api.weibo.com/oauth2/authorize"
  REQUEST_WEIBO_TOKEN={
    :response_type=>"token",
    :client_id=>"3987186573",
    :redirect_uri=>"#{Constant::SERVER_PATH}/logins/respond_weibo"
  }
 

  #构造post请求
  def create_post_http(url,route_action,params)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.port==443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Post.new(route_action)
    request.set_form_data(params)
    return JSON http.request(request).body
  end

  #构造get请求
  def create_get_http(url,route)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.port==443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request= Net::HTTP::Get.new(route)
    back_res =http.request(request)
    return JSON back_res.body
  end

  #人人网签名
  def sig_renren(query)
    str=""
    query.sort.each{|key,value|str<<"#{key}=#{value}"}
    str<<RENREN_API_SECRET
    query[:sig]=Digest::MD5.hexdigest(str)
    return query
  end

  #记录分享和关注的返回记录
  def share_log(type,con)
    dir = "#{Rails.root}/public/log"
    Dir.mkdir(dir)  unless File.directory?(dir)
    file_path = dir+"/#{Time.now.strftime("%Y%m%d")}.txt"
    if File.exists? file_path
      file = File.open( file_path,"a")
    else
      file = File.new(file_path, "w")
    end
    file.puts "#{type}------#{con}----#{Time.now.strftime('%Y%m%d %H:%M:%S')}\r\n"
    file.close
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
        data="成功"
      end
    else
      data="失败"
    end
    share_log("qq微博 guanzhu",data)
  end

  #新浪微博获取用户信息
  def sina_get_user(access_token,uid)
    response = create_get_http("https://api.weibo.com","/2/users/show.json?access_token=#{access_token}&uid=#{uid}")
  end
  #
  #新浪微博发送微博
  def sina_send_message(access_token,message)
    response =create_post_http("https://api.weibo.com","/2/statuses/update.json",{"access_token" =>access_token, "status" => message})
  end

  # 带图片微博
  def sina_send_pic(access_token,message,img_url)
    url = URI.parse("https://api.weibo.com/2/statuses/upload.json")
    File.open("#{Rails.root}/public/#{img_url}") do |jpg|
      req = Net::HTTP::Post::Multipart.new url.path,{"access_token" =>access_token, "status" => message,"pic" => UploadIO.new(jpg, "image/jpeg", "image.jpg")}
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      info= http.request(req).body
#      share_log("renren share", response.map{|k,v|  "#{k}=#{v}"}.join('&'))
#      share_log("sina share", info.to_s)
      return info
    end
   
  end

  #人人获取用户信息
  def renren_get_user(access_token)
    query = {:access_token => access_token,:format => 'JSON',:method => 'xiaonei.users.getInfo',:v => '1.0'}
    response=create_post_http("http://api.renren.com","/restserver.do",sig_renren(query))
  end
  #
  #人人发送新鲜事
  def renren_send_message(access_token,message,other_parms=nil)
    other_parms={:type=>"6",:url=>"http://www.gankao.co"} if other_parms.nil?
    query = {:access_token => "#{access_token}",:comment=>"#{message}",:format => 'JSON',:method => 'share.share',:v => '1.0'}
    query.merge!(other_parms)
    response=create_post_http("http://api.renren.com","/restserver.do",sig_renren(query)) 
    share_log("renren share", response.map{|k,v|  "#{k}=#{v}"}.join('&'))
    return response
  end




  #qq添加说说
  def send_message_qq(con,user,other_parms=nil)
    send_parms={:access_token=>user.access_token,:openid=>user.open_id,:oauth_consumer_key=>Oauth2Helper::APPID,:format=>"json",:third_source=>"3",:con=>con}
    send_parms.merge!(other_parms)
    info=create_post_http("https://graph.qq.com","/shuoshuo/add_topic",send_parms)
    if info["data"]["ret"].nil?
      data= "qq error_code #{info["data"]["ret"]}"
    else
      data= "qq user #{user.id}  send success"
    end
    share_log("qq share",data)
  end

  #qq分享
  def send_share_qq(share_to,user,other_parms=nil)
    send_parms={:access_token=>user.access_token,:openid=>user.open_id,:oauth_consumer_key=>Oauth2Helper::APPID,:format=>"json"}
    send_parms.merge!(other_parms)
    info=create_post_http("https://graph.qq.com",share_to,send_parms)
    share_log("qq share",info)
    return info
  end

  #根据用户类型发送消息
  def send_message(message,user_id)
    begin
      user=User.find(user_id)
      if !user.access_token.nil? and user.access_token!="" and !user.end_time.nil? and user.end_time>Time.now
        message +="赶考网http://www.gankao.co --#{Time.now.strftime(("%Y-%m-%d"))}"
        if user.code_type=="qq" and !user.open_id.nil?
          send_message_qq(message,user)
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
