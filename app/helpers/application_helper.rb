module ApplicationHelper
  include LearnHelper

  def sign?
    cookies[:user_id] = 42
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
    if cookies[:user_id]
      user_id = cookies[:user_id]
      user = User.find_by_id(user_id.to_i)
      if user
        num= params[:category] ? get_user_sun_nums(user,params[:category].to_i) : 0
        yestoday_suns = params[:category] ? get_yestoday_suns(params[:category].to_i, user_id) : 0
        @user={:name => user.name, :school => user.school, :email => user.email,
          :signin_days => user.signin_days, :login_times => user.login_times,
          :num => num, :cover_url => user.cover_url, :yestoday_suns => yestoday_suns}
      end
    end
  end
  
  #获取用户的所有太阳数
  def get_user_sun_nums(user,category)
    sun=Sun.find_by_sql("select ifnull(sum(num), 0) num from suns where category_id=#{category} and user_id=#{user.id}")[0]
    return sun.nil? ? 0 : sun.num.to_i
  end

  #获取昨天各科目获得的太阳
  def get_yestoday_suns(category_id, user_id)
    suns = Sun.find_by_sql(["select ifnull(sum(num), 0) total_num from suns where category_id = ?
          and TO_DAYS(NOW())-TO_DAYS(created_at)=1 and user_id = ?",
        category_id, user_id])[0]
    return suns.nil? ? 0 : suns.total_num.to_i
  end

  #考研的倒计时
  def from_kaoyan
    exam_date=Constant::DEAD_LINE[:GRADUATE].to_datetime
    ((exam_date.to_i-Time.now.to_i)/(3600*24)).round
  end

  #获得用户当前的分数
  def get_current_score
    max_score = UserScoreInfo.return_max_score(params[:category].to_i) #最大分数
    score_arr = ["5", "0", "#{max_score}", "0"]  #比例、开始、结束、目前状况
    if cookies[:user_id]
      user_score_info = UserScoreInfo.find_by_category_id_and_user_id(params[:category].to_i, cookies[:user_id].to_i)
      if user_score_info
        user_plan = UserPlan.find_by_category_id_and_user_id(params[:category].to_i, cookies[:user_id].to_i)
        if user_plan
          doc = user_plan.plan_list_xml
          current_package = doc.root.elements["plan"].elements["current"].text.to_i
          current_score = user_score_info.show_user_score(current_package, user_plan.days)
          current_percent = ((current_package.to_f/user_plan.days)*100).round
          score_arr = ["#{current_percent}", "#{user_score_info.start_score}", "#{max_score}", "#{current_score}"]
        end
      end
    end
    return score_arr.join(",")
  end
  
  #用户登录天数
  def signin_days(user,category_id)
    hash=Hash.new()
    p hash=user.signin_days.split(',').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
    p Category::FLAG[category_id.to_i]
    p hash[Category::FLAG[category_id.to_i]].to_i
    return hash[Category::FLAG[category_id.to_i]].to_i
  end

  def show_focus
    if cookies[:user_id] and Sun.find_by_sql("select * from suns where user_id=#{cookies[:user_id].to_i} and
      types=#{Sun::TYPES[:LOGIN_MORE]} and category_id=#{params[:category].to_i}")[0].nil? and
        user_info[:login_times].to_i==4
      return true
    else
      return false
    end
  end
end
