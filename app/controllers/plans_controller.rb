#encoding: utf-8
class PlansController < ApplicationController
  layout 'main'
  before_filter :sign?, :except => ["index", "end_result", "show_result"]
  
  def index
    cookies[:user_id]=5
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
    @user_score_info = UserScoreInfo.find_by_category_id_and_user_id(category, cookies[:user_id].to_i) if cookies[:user_id]
    if @user_score_info
      @user_plan = UserPlan.find_by_category_id_and_user_id(category, cookies[:user_id].to_i)
      if @user_plan
        #显示计划列表
        @plan_list = @user_plan.get_plan_list
      end
    end
  end

  #显示部分
  def show_chapter
    @user_plan = UserPlan.find(params[:plan_id].to_i)
    @plan_list = @user_plan.get_plan_list
    @chapter_num = params[:chapter_num].to_i
    @direction = params[:direction]
    respond_to do |format|
      format.js
    end
  end

  def show_result
    @category=params[:category].to_i
    if params[:info].nil?
      redirect_to "/plans?category=#{@category}"
    else
      cookies[:info] = {:value => params[:info], :path => "/", :secure  => false}
      redirect_to "/plans/end_result?category=#{@category}"
    end
  end

  def end_result
    @category=params[:category].to_i
    if cookies[:info].nil?
      redirect_to "/plans?category=#{@category}"
    else
      @score = cookies[:info].split(",")
      @user = User.find(cookies[:user_id].to_i) if cookies[:user_id]
    end 
  end

  
  def create_plan
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    scores=params[:level_score].split(",")
    t_score=scores.pop
    plans=UserPlan.calculate_user_plan_info(scores.join(","), category, params[:target_score].to_i)
    score=plans[:TARGET_SCORE].nil? ? params[:target_score].to_i : plans[:TARGET_SCORE].to_i
    paras={:category_id=>category,:user_id=>cookies[:user_id],:all_start_level=>scores.join(","),:start_score=>t_score,:target_score=>score}
    plans.merge!(:DAYS=>UserPlan.package_level(category))
   @plan_score = plans[:TARGET_SCORE] if (plans[:TARGET_SCORE] and plans[:TARGET_SCORE] > UserScoreInfo::PASS_SCORE[:"#{Category::FLAG[category]}"])
    @user_plan=[js_hash(plans),js_hash(paras),User.find(cookies[:user_id])]
    respond_to do |format|
      format.js
    end
  end

  def js_hash(plans)
    user_plan={}
    plans.each do |k,v|
      user_plan["#{k}"]="#{v}"
    end
    return "#{user_plan}".gsub("=>",":")
  end

  def init_plan
    data_info=rails_hash(params[:plan_infos])
    user_score_info=create_user_score(params[:category_id].to_i,rails_hash(params[:score_info]))
    UserPlan.init_plan(user_score_info, data_info, cookies[:user_id].to_i, params[:category_id].to_i)
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end

  def create_user_score(category,score_info)
    user_score=UserScoreInfo.find_by_category_id_and_user_id(params[:category_id].to_i,cookies[:user_id])
    if user_score
      user_score.update_attributes(score_info)
    else
      user_score=UserScoreInfo.create(score_info)
      user_score.set_user_modulus
      Sun.complete_test(category, cookies[:user_id].to_i)
    end
    return user_score
  end

  def rails_hash(plan_infos)
    plan_infos=ActiveSupport::JSON.decode plan_infos
    data_info={}
    plan_infos.each do |k,v|
      if v.split(",").length>1
        data_info[:"#{k}"]=v
      else
        data_info[:"#{k}"]=v.to_i
      end
    end
    return data_info
  end


  def update_user
    user=User.find(cookies[:user_id])
    infos={:email=>params[:p_email]}
    infos.merge!(:remarks=>"#{user.remarks} qq:#{params[:p_qq]}") unless params[:p_qq]==""
    user.update_attributes(infos)
    redirect_to "/plans?category=#{params[:category_id]}"
  end

  def retest
    cookies[:retest] = {:value => true, :path => "/", :secure  => false}
    redirect_to "/plans?category=#{params[:category]}"
  end

end
