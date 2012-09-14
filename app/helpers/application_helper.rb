#encoding: utf-8
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
    unless cookies[:user_id].nil?
      cookies[:user_role] = {:value => "", :path => "/", :secure  => false}
      orders = Order.find(:all, :conditions => ["status = #{Order::STATUS[:NOMAL]} and user_id = ?", user_id.to_i])
      orders.each do |order|
        this_order = "#{order.category_id}=#{Order::USER_ORDER[:VIP]}"
        cookies[:user_role] = cookies[:user_role].empty? ? this_order : (cookies[:user_role] + "&" + this_order)
      end unless orders.blank?
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
          :num => num, :img_url => user.img_url, :yestoday_suns => yestoday_suns}
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
  def from_kaoyan(category_id)
    count_down = ['', '']
    case category_id.to_i
    when Category::TYPE[:CET4]
      count_down[0] = "四级"
      count_down[1] = ((Constant::EXAM_DATE[:CET4].to_datetime.to_i-Time.now.to_date.to_datetime.to_i)/(3600*24)).round
    when Category::TYPE[:CET6]
      count_down[0] = "六级"
      count_down[1] = ((Constant::EXAM_DATE[:CET6].to_datetime.to_i-Time.now.to_date.to_datetime.to_i)/(3600*24)).round
    when Category::TYPE[:GRADUATE]
      count_down[0] = "考研"
      count_down[1] = ((Constant::EXAM_DATE[:GRADUATE].to_datetime.to_i-Time.now.to_date.to_datetime.to_i)/(3600*24)).round
    end
    return count_down
  end

  #获得用户当前的分数
  def get_current_score
    max_score = UserScoreInfo.return_max_score(params[:category].to_i) #最大分数
    pass_score = UserScoreInfo::PASS_SCORE[:"#{Category::FLAG[params[:category].to_i]}"] #过关分数
    score_arr = ["5", "0", "#{max_score}", "0"]  #比例、开始、结束、目前状况
    if cookies[:user_id]
      user_score_info = UserScoreInfo.find_by_category_id_and_user_id(params[:category].to_i, cookies[:user_id].to_i)
      if user_score_info
        user_plan = UserPlan.find_by_category_id_and_user_id(params[:category].to_i, cookies[:user_id].to_i)
        if user_plan
          doc = user_plan.plan_list_xml
          current_package = doc.root.elements["plan"].elements["current"].text.to_i - 1
          current_score = user_score_info.show_user_score(current_package, user_plan.days)
          current_percent = ((current_package.to_f/user_plan.days)*100).round
          current_percent = current_percent < 5 ? 5 : current_percent
          end_score = user_score_info.target_score < pass_score ? pass_score : user_score_info.target_score
          score_arr = ["#{current_percent}", "#{user_score_info.start_score}", "#{end_score}", "#{current_score}"]
        end
      end
    end
    return score_arr.join(",")
  end
  
  #用户登录天数
  def signin_days(signin_days,category_id)
    hash=Hash.new()
    hash=signin_days.split(',').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
    user_sun=Sun.find_by_sql("select id from suns where category_id=#{category_id.to_i} and types=#{Sun::TYPES[:SIGNIN]}
    and user_id=#{cookies[:user_id].to_i} and TO_DAYS(NOW())-1=TO_DAYS(created_at)")[0]
    if user_sun
      return hash[Category::FLAG[category_id.to_i]].to_i
    else
      return 0
    end    
  end

  def show_focus
    if cookies[:user_id] and Sun.find_by_sql("select * from suns where user_id=#{cookies[:user_id].to_i} and
      types=#{Sun::TYPES[:LOGIN_MORE]} and category_id=#{params[:category].to_i}")[0].nil? and
        user_info and user_info[:login_times].to_i >3
      return true
    else
      return false
    end
  end

  #寻找句子中相同的单词
  def leving_word(sentence, word)
    lev_word = case
    when sentence =~/#{word}/
      word
    when sentence =~/#{word.capitalize}/
      word
    when sentence =~/#{word[0, word.length-1]}/
      word[0, word.length-1]
    when sentence =~/#{word[0, word.length-2]}/
      word[0, word.length-2]
    else word
    end
    return lev_word
  end

  # 中英文混合字符串截取
  def truncate_u(text, length = 30, truncate_string = "......")
    l=0
    char_array=text.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l+ (c<127 ? 0.5 : 1)
      if l>=length
        return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
      end
    end
    return text
  end

  #是否已经生成复习计划
  def is_has_plan?
    is_has_plan = false
    if cookies[:user_id] and params[:category]
      if @user_plan
        is_has_plan = true
      else
        user_plan = UserPlan.find_by_category_id_and_user_id(params[:category].to_i, cookies[:user_id].to_i)
        is_has_plan = true unless user_plan.nil?
      end
    end
    return is_has_plan
  end
  
end
