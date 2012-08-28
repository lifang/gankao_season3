class UsersController < ApplicationController
  include Oauth2Helper
  before_filter :sign?, :except => ["share_back"]
  
  #更新用户信息
  def update_users
    user = User.find(cookies[:user_id].to_i)
    if user
      params[:info][:username] = user.username if params[:info][:username].nil? or params[:info][:username].empty?
      params[:info][:name] = user.name if params[:info][:name].nil? or params[:info][:name].empty?
      params[:info][:email] = user.email if params[:info][:email].nil? or params[:info][:email].empty?
      params[:info][:school] = user.school if params[:info][:school].nil? or params[:info][:school].empty?
      params[:info][:mobilephone] = user.mobilephone if params[:info][:mobilephone].nil? or params[:info][:mobilephone].empty?
      user.update_attributes(params[:info])
    end
    data="个人信息更新成功。"
    respond_to do |format|
      format.json {
        render :json=>{:message=>data}
      }
    end
  end
 
  #签到
  def check_in
    category = params[:category].empty? ? 2 : params[:category].to_i
    user=User.find(cookies[:user_id].to_i)
    user_sun=Sun.find_by_sql("select * from suns where category_id=#{category}
      and types=#{Sun::TYPES[:SIGNIN]} and user_id=#{user.id} 
       and TO_DAYS(NOW())=TO_DAYS(created_at)")[0]
    if user_sun
      data="你今天已经签过到了哦~~~"
      hash=Hash.new()
      hash=user.signin_days.split(',').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
    else
      Sun.create(:user_id=>user.id,:category_id=>category,:types=>Sun::TYPES[:SIGNIN],:num=>Sun::TYPE_NUM[:SIGNIN])
      data="签到成功，获得1个小太阳。"
      #连续签到 +1 没有连续变为1
      hash=Hash.new()
      hash=user.signin_days.split(',').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
      if check_everyday(user.id,category) 
        hash[Category::FLAG[category]]=((hash[Category::FLAG[category]].to_i)+1).to_s
      else
        hash[Category::FLAG[category]]='1'
      end
      user.signin_days=hash.map{|k,v| "#{k}"+"=>"+"#{v}"}.join(',')
      user.save
      data = data+"连续签到5天，奖励1个小太阳，并有机会得到额外奖励的1~2个小太阳!"
      if check_keep_on_login(user.id,category)
        #连续登录5天奖励一个小太阳
        Sun.create(:user_id=>user.id,:category_id=>category,:types=>Sun::TYPES[:KEEP_ON_LOGIN],:num=>Sun::TYPE_NUM[:KEEP_ON_LOGIN])       
        #随机奖励
        num = (rand*(Sun::TYPE_NUM[:RANDOM_AWARD].to_i+1)).to_i #随机[0,2]
        if num!=0
          Sun.create(:user_id=>user.id,:category_id=>category,:types=>Sun::TYPES[:RANDOM_AWARD],:num=>num)
        end
      end
    end
    total_num = get_user_sun_nums(user,category)
    respond_to do |format|
      format.json {
        render :json=>{:message=>data,:num=>num,:days=>hash[Category::FLAG[category]].to_i}
      }
    end
  end

  #是否签到 按日期比较的
  def check_everyday(id,category)
    user_sun=Sun.find_by_sql("select id from suns where category_id=#{category} and types=#{Sun::TYPES[:SIGNIN]}
    and user_id=#{id} and TO_DAYS(now())-1=TO_DAYS(created_at)")[0]
    if user_sun
      return true
    else
      return false
    end
  end

  #是否连续5天登录
  def check_keep_on_login(user_id,category)
    count=Sun.count_by_sql("select count(id) signin_count from suns where category_id=#{category} and user_id=#{user_id}
      and types=#{Sun::TYPES[:SIGNIN]}
      and TO_DAYS(created_at)>TO_DAYS(now())-5 and TO_DAYS(created_at)<=TO_DAYS(now())")
    if count >= 5
      return true
    else
      return false
    end
  end
  
  #分享
  def share
    @web= params[:web].to_s
    category=params[:category].to_i
    level=case category
    when 2 then "英语4级"
    when 3 then "英语6级"
    else "考研英语"
    end
    @message="我在赶考网复习"+level
    #获取用户
    user=User.find_by_id_and_code_type(cookies[:user_id],@web)
   
    if user and user.access_token and (user.end_time-Time.now>0)
      @message=@message+",来自链接:"+Constant::SERVER_PATH+"/users/#{user.id}/share_back?category=#{category}"
      if @web=="sina"
        type=Sun::TYPES[:SINASHARE].to_i
        ret = sina_send_message(user.access_token, @message)
        @return_message = "微博发送失败，请重新尝试" if ret["error_code"]
      elsif @web=="renren"
        type=Sun::TYPES[:RENRENSHARE].to_i
        ret = renren_send_message(user.access_token, @message)
        @return_message = "分享失败，请重新尝试" if ret[:error_code]
      end
      if @return_message.nil?
        render :text=>update_user_suns(user,category,type)
      else
        render :text=>@return_message
      end
    else
      if params[:web].to_s=="sina"
        redirect_to "https://api.weibo.com/oauth2/authorize?client_id=#{Oauth2Helper::SINA_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_sina&response_type=token"
      elsif params[:web].to_s=="renren"
        redirect_to "http://graph.renren.com/oauth/authorize?response_type=token&client_id=#{Oauth2Helper::RENREN_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_renren"
      end
    end
  end
  
  #更新用户太阳数--分享成功
  def update_user_suns(user,category,type)
    user_sun=user.suns.where("category_id=#{category} and types=#{type}").find(:all)[0]
    if user_sun  #有分享记录，则不再赠送小太阳
      data="分享成功"
    else
      Sun.create(:user_id=>user.id,:category_id=>category,:types=>type,:num=>Sun::TYPE_NUM[:SHARE])
      data="分享成功,获得2个小太阳."
    end
    return data
  end
 
  #推荐网站，获得小太阳
  def share_back
    user=User.find(params[:id].to_i)
    category=params[:category].to_i
    count=Sun.count_by_sql("select count(*) commend_count from suns where types=#{Sun::TYPES[:COMMEND]} and
       category_id=#{category} and user_id=#{user.id}")
    if count<5
      Sun.create(:user_id=>user.id,:category_id=>category,:types=>Sun::TYPES[:COMMEND],:num=>Sun::TYPE_NUM[:COMMEND])
    end
    redirect_to Constant::SERVER_PATH+"/plans?category=#{category}"
  end
  
  #用户登录三次提示分享网站和关注
  def kaoyan_share
    @web= params[:web].to_s
    message=params[:message].to_s
    user=User.find_by_id_and_code_type(cookies[:user_id],@web)
 
    message="我选择赶考因为："+message
    if user and user.access_token and (user.end_time-Time.now>0)
      if @web=="sina"
        ret = sina_send_message(user.access_token, message)
        @return_message ="微博发送失败，请重新尝试" if ret["error_code"]
        #分享成功
        if @return_message.nil?
          #送5个太阳
          focus_and_share_sun(user.id,Category::TYPE[:GRADUATE])
        end
        render :text=>request_weibo(user.access_token,user.code_id,"关注失败，请登录微博查看")
      elsif @web=="renren"
        ret = renren_send_message(user.access_token, message)
        @return_message = "分享失败，请重新尝试" if ret[:error_code]
        #分享成功
        if @return_message.nil?
          #送5个太阳
          focus_and_share_sun(user.id,Category::TYPE[:GRADUATE])
        end
        redirect_to "http://widget.renren.com/dialog/friends?target_id=#{Oauth2Helper::RENREN_ID}&app_id=163813&redirect_uri=#{Constant::SERVER_PATH}"
      elsif @web=="qq"
        info=share_tencent_weibo(user.access_token,user.open_id,message)
        @return_message="腾讯微博分享失败，请重新尝试" if info["ret"].to_i!=0
        #分享成功
        if @return_message.nil?
          #送5个太阳
          focus_and_share_sun(user.id,Category::TYPE[:GRADUATE])
        end
        info=focus_tencent_weibo(user.access_token,user.open_id)
        @return_message="关注腾讯微博失败" if info["ret"].to_i!=0
        if @return_message.nil?
          render :text=>"关注腾讯微博成功"
        else
          render :text=>@return_message
        end
      end
    else
      if @web=="sina"
        redirect_to "https://api.weibo.com/oauth2/authorize?client_id=#{Oauth2Helper::SINA_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_sina&response_type=token"
      elsif @web=="renren"
        redirect_to "http://graph.renren.com/oauth/authorize?response_type=token&client_id=#{Oauth2Helper::RENREN_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_renren"
      elsif @web=="qq"
        redirect_to "#{Oauth2Helper::REQUEST_URL_QQ}?#{Oauth2Helper::REQUEST_ACCESS_TOKEN.map{|k,v|"#{k}=#{v}"}.join("&")}"
      end
    end
  end
  #关注和分享网站,奖励5个小太阳
  def focus_and_share_sun(id,category)
    user_sun=Sun.find_by_sql("select * from suns where user_id=#{id} and category_id=#{category} and types=#{Sun::TYPES[:LOGIN_MORE]}")[0]
    if user_sun
      return "已经奖励了"
    else
      Sun.create(:user_id=>id,:category_id=>category.to_i,:types=>Sun::TYPES[:LOGIN_MORE],:num=>Sun::TYPE_NUM[:LOGIN_MORE])
      return "获得5个小太阳"
    end
  end
end
