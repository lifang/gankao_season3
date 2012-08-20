class UsersController < ApplicationController
  def index
    cookies[:user_id]=1
    user_id=cookies[:user_id]
    category=params[:category].nil?? "2":params[:category]
    @user=Sun.find_by_sql("select users.name,users.school,users.email,suns.num from users,suns where
      users.id=suns.user_id and users.id=#{user_id} and suns.category_id=#{category}")[0]
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
    user_sun=user.suns.where("category_id=#{category}").find(:all)[0]
 
    if user_sun.nil?
      Sun.create(:user_id=>user[:id],:category_id=>category,:types=>1,:num=>1)
      data="签到成功，获得一个小太阳。"
      num=1
    else
      if is_check?(user_sun)
        data="你已经签过到了！！！"
      else
        user_sun.num.to_i+=1
        user_sun.save
        data="签到成功，获得一个小太阳。"
      end
      num=user_sun.num
    end
    respond_to do |format|
      format.json {
        render :json=>{:message=>data,:num=>num}
      }
    end
  end
  def is_check?(user_sun)
    #获取上一次更新时间-日期
    update_date=user_sun.updated_at.strftime("%Y%m%d").to_i
    #获取当前时间-日期
    date_now=Time.now.strftime("%Y%m%d").to_i
    return update_date==date_now
  end
end
