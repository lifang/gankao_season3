class UsersController < ApplicationController
  def index
    cookies[:user_id]=1
    user_id=cookies[:user_id]
    @user=User.find_by_sql("SELECT users.name,users.school,users.email,suns.num FROM
          users,suns where users.id=suns.user_id where user.id=?",user_id)

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
    user=User.find(cookies[:user_id])
    if is_check?(user)
      data="你已经签过到了！！！"
      num=user.sun.num
    else
      user_sun=user.sun
      if user_sun.nil?
        Sun.create(:user_id=>user[:id],:category_id=>cookies[:category_id],:types=>1,:num=>1)
      else
        user_sun.num+=1
        user_sun.save
      end
      data="签到成功，获得一个小太阳。"
      num=user_sun.num
    end
    respond_to do |format|
      format.json {
        render :json=>{:message=>data,:num=>num}
      }
    end
  end
  def is_check?(user)
    u_s=user.sun
    #获取上一次更新时间-日期
    update_date=u_s.updated_at.strftime("%Y%m%d").to_i
    #获取当前时间-日期
    date_now=Time.now.strftime("%Y%m%d").to_i
    return update_date==date_now
  end
end
