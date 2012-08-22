class UsersController < ApplicationController
  include Oauth2Helper
  def index
    cookies[:user_id]=1
    user_id=cookies[:user_id]
    category=params[:category].nil?? "2":params[:category]
    user=User.find(user_id)
    num= get_user_sun_nums(user,category)
    @user={:name=>user[:name],:school=>user[:school],:email=>user[:email],:num=>num}
  end
  #更新用户信息
  def update_users
    cookies[:user_id]='1'
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
    cookies[:user_id]=1
    category=params[:category].empty?? 2:params[:category].to_i
    user=User.find(cookies[:user_id])
    user_sun=user.suns.where("category_id=#{category} and types=#{Sun::TYPES[:SIGNIN]}").find(:all)[0]
    if user_sun.nil?
      Sun.create(:user_id=>user.id,:category_id=>category,:types=>Sun::TYPES[:SIGNIN],:num=>Sun::TYPE_NUM[:SIGNIN])
      data="签到成功，获得1个小太阳。"
      num=1
    else
      if is_check?(user_sun)
        data="你已经签过到了！！！"
      else
        user_sun.num=user_sun.num.to_i+1
        user_sun.save
        data="签到成功，获得1个小太阳。"
      end
      num=get_user_sun_nums(user,category)
    end
    respond_to do |format|
      format.json {
        render :json=>{:message=>data,:num=>num}
      }
    end
  end

  #是否签到、分享 按日期比较的
  def is_check?(user_sun)
    #获取上一次更新时间-日期
    update_date=user_sun.updated_at.strftime("%Y%m%d").to_i
    #获取当前时间-日期
    date_now=Time.now.strftime("%Y%m%d").to_i
    return update_date==date_now
  end
  #分享
  def check_login
    @web= params[:web].to_s
    category=params[:category].to_i
    level=case category
    when 2 then "英语4级"
    when 3 then "英语6级"
    else "考研英语"
    end
    @message="我在赶考网复习"+level
    #获取用户
    cookies[:user_id]=77
    user=User.find_by_id_and_code_type(cookies[:user_id],@web)
   
    if user and user.access_token and (user.end_time-Time.now>0)
      @message=@message+",来自链接:"+Constant::SERVER_PATH+"/users/#{user.id}/share_back?category=#{category}"
      if @web=="sina"
        ret = sina_send_message(user.access_token, @message)
        @return_message = "微博发送失败，请重新尝试" if ret["error_code"]
      elsif @web=="renren"
        ret = renren_send_message(user.access_token, @message)
        @return_message = "分享失败，请重新尝试" if ret[:error_code]
      end
      if @return_message.nil?
        render :text=>update_user_suns(user,category)
      else
        render :text=>@return_message
      end
    else
      if params[:web].to_s=="sina"
        redirect_to "https://api.weibo.com/oauth2/authorize?client_id=#{Constant::SINA_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_sina&response_type=token"
      elsif params[:web].to_s=="renren"
        redirect_to "http://graph.renren.com/oauth/authorize?response_type=token&client_id=#{Constant::RENREN_CLIENT_ID}&redirect_uri=#{Constant::SERVER_PATH}/logins/respond_renren"
      end
    end
  end
  #更新用户太阳数
  def update_user_suns(user,category)
    user_sun=user.suns.where("category_id=#{category} and types=#{Sun::TYPES[:SHARE]}").find(:all)[0]
    if is_check?(user_sun)
      data="分享成功"
    else
      if user_sun.nil?
        Sun.create(:user_id=>user.id,:category_id=>category,:types=>Sun::TYPES[:SHARE],:num=>Sun::TYPE_NUM[:SHARE])
      else
        user_sun.num=user_sun.num.to_i+Sun::TYPE_NUM[:SHARE]
        user_sun.save
      end
      data="分享成功,获得2个小太阳."
    end
    return data
  end
  #推荐网站，获得小太阳
  def share_back
    user=User.find(params[:id].to_i)
    category=params[:category]
    count=Sun.find_by_sql("select count(*) commend_count from suns where types=#{Sun::TYPES[:COMMEND]} and
       category_id=#{category} and user_id=#{user.id}")[0].commend_count
    if count<5
      Sun.create(:user_id=>user.id,:category_id=>category,:types=>Sun::TYPES[:COMMEND],:num=>Sun::TYPE_NUM[:COMMEND])
    end
    redirect_to Constant::SERVER_PATH
  end
end
