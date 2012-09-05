#encoding: utf-8
class PlansController < ApplicationController
  layout 'main'
  before_filter :sign?, :except => ["index", "end_result"]
  
  def index
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
    @user_score_info = UserScoreInfo.find_by_category_id_and_user_id(category, cookies[:user_id].to_i) if cookies[:user_id]
    if @user_score_info
      @user_plan = UserPlan.find_by_category_id_and_user_id(category, cookies[:user_id].to_i)
      if @user_plan
        #显示计划列表
        @plan_list = @user_plan.get_plan_list
        #else
        #生成初始的计划
        #data_info = {:ONE=>2800, :TWO=>1460, :THREE=>875, :ALL=>5135, :WORD=>94,
        #  :SENTENCE=>47, :READ=>96, :WRITE=>96, :LISTEN=>47, :TRANSLATE=>500, :DICTATION=>500, :DAYS => 86, :TARGET_SCORE => 400}
        #@user_plan = UserPlan.init_plan(@user_score_info, data_info, cookies[:user_id].to_i, category)
        #@plan_list = @user_plan.get_plan_list
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


  def end_result
    @category=params[:category].to_i
    if params[:info].nil?
      redirect_to "/plans?category=#{@category}"
    else
      @score=params[:info].split(",")
      @t_score=@score.pop
      if cookies[:user_id]
        create_user_score(@category,@score,@t_score)
      end
    end
  
  end

  def create_user_score(category,scores,start_score=nil)
    paras={:category_id=>category,:user_id=>cookies[:user_id],:all_start_level=>scores.join(","),:start_score=>start_score}
    user_score=UserScoreInfo.find_by_category_id_and_user_id(category,cookies[:user_id])
    if user_score
      user_score.update_attributes(paras)
    else
      user_score=UserScoreInfo.create(paras)
      user_score.set_user_modulus
      Sun.complete_test(category, cookies[:user_id].to_i)
    end
  end

  def create_plan
    category=params[:category_id].nil? ? 4 : params[:category_id].to_i
    user_score=UserScoreInfo.find_by_category_id_and_user_id(category,cookies[:user_id])
    user_score.update_attributes(:target_score=>params[:target_score].to_i)
    plans=UserPlan.calculate_user_plan_info(cookies[:user_id], category, params[:target_score].to_i)
    plans.merge!(:DAYS=>UserPlan.package_level(category))
    @user_plan={}
    plans.each do |k,v|
      @user_plan["#{k}"]="#{v}"
    end
    respond_to do |format|
      format.js
    end
  end

  def init_plan
    user_score_info = UserScoreInfo.find_by_category_id_and_user_id(params[:category_id].to_i, cookies[:user_id].to_i)
    plan_infos=ActiveSupport::JSON.decode params[:plan_infos]
    data_info={}
    plan_infos.each do |k,v|
      data_info[:"#{k}"]=v.to_i
    end
    UserPlan.init_plan(user_score_info, data_info, cookies[:user_id].to_i, params[:category_id].to_i)
    respond_to do |format|
      format.json {
        render :json=>"1"
      }
    end
  end

  def update_user
    user=User.find(cookies[:user_id])
    infos={:email=>params[:p_email]}
    infos.merge!(:name=>params[:p_name]) unless params[:p_name]==""
    infos.merge!(:remarks=>"#{user.remarks} qq:#{params[:p_qq]}") unless params[:p_qq]==""
    user.update_attributes(infos)
    redirect_to "/plans?category=#{params[:category_id]}"
  end

end
