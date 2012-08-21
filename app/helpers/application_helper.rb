module ApplicationHelper
  include LearnHelper
  #获取当前用户的基本信息和小太阳个数
  def user_info
    cookies[:user_id]=1
    user_id=cookies[:user_id]
    category=params[:category].nil?? "2":params[:category]
    user=User.find(user_id)
    user_sun=user.suns.where("category_id=#{category}").find(:all)[0]
    if user_sun.nil?
      num=0
    else
      num=user_sun.num.to_i
    end
    user={:name=>user[:name],:school=>user[:school],:email=>user[:email],:num=>num}
  end
end
