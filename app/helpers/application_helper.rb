module ApplicationHelper
  include LearnHelper

  def sign?
    deny_access unless signed_in?
  end
  
  def deny_access
    redirect_to "/logins?last_url=#{request.url}"
  end

  def signed_in?
    return cookies[:user_id] != nil
  end

  #判断是否vip、试用用户或普通用户
  def user_role?(user_id)
    unless cookies[:user_id].nil? or params[:category].nil?
      if cookies[:user_role].nil?
        cookies[:user_role] = {:value => "", :path => "/", :secure  => false}
        orders = Order.find(:all, :conditions => ["status = #{Order::STATUS[:NOMAL]} and user_id = ?", user_id.to_i])
        orders.each do |order|
          this_order = "#{order.category_id}=#{Order::USER_ORDER[:TRIAL]}"
          cookies[:user_role] = cookies[:user_role].empty? ? this_order : (cookies[:user_role] + "&" + this_order)
        end unless orders.blank?
      end
    end
  end

  #判断有没有当前分类的权限
  def category_role(category_id)
    current_role = Order::USER_ORDER[:NOMAL]
    user_role?(cookies[:user_id]) if cookies[:user_role].nil?
    all_category = cookies[:user_role].split("&")
    all_category.each do |category|
      if category.include?("#{category_id}=")
        current_role = category.split("=")[1]
      end
    end unless all_category.blank?
    return current_role.to_i
  end


  #判断是否vip
  def is_vip?(category_id)
    return category_role(category_id) == Order::USER_ORDER[:VIP]
  end

  #是否普通用户
  def is_nomal?(category_id)
    return category_role(category_id) == Order::USER_ORDER[:NOMAL]
  end
  
  #获取当前用户的基本信息和小太阳个数
  def user_info
    cookies[:user_id]=1
    user_id=cookies[:user_id]
    category=params[:category].nil?? "2":params[:category]
    user=User.find(user_id)
    num= get_user_sun_nums(user,category)
    @user={:name=>user[:name],:school=>user[:school],:email=>user[:email],:num=>num}
  end
  #获取用户的所有太阳数
  def get_user_sun_nums(user,category)
    num=0
    num=Sun.find_by_sql("select sum(num) num from suns where category_id=#{category} and user_id=#{user.id}")[0].num
    return num
  end
end
