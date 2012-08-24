class PlansController < ApplicationController
  layout 'main'
  
  def index
    cookies[:user_id] = 35  #登录做完之后要删除
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
    @user_score_info = UserScoreInfo.find_by_category_id_and_user_id(category, cookies[:user_id].to_i)
    if @user_score_info
      @user_plan = UserPlan.find_by_category_id_and_user_id(category, cookies[:user_id].to_i)
      if @user_plan
        #显示计划列表
        @plan_list = @user_plan.get_plan_list
        puts "===============start test update plan=================="
        #@user_plan.update_plan
      else
        #生成初始的计划
        data_info = {:ONE=>2800, :TWO=>1460, :THREE=>875, :ALL=>5135, :WORD=>94,
          :SENTENCE=>47, :READ=>96, :WRITE=>96, :LISTEN=>47, :TRANSLATE=>500, :DICTATION=>500, :DAYS => 86, :TARGET_SCORE => 400}
        @user_plan = UserPlan.init_plan(@user_score_info, data_info, cookies[:user_id].to_i, category)
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

end
