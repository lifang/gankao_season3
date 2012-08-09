class PlansController < ApplicationController
  layout 'main'
  
  def index
    cookies[:user_id] = 1  #登录做完之后要删除
    @user_score_info = UserScoreInfo.find_by_category_id_and_user_id(params[:category_id].to_i, cookies[:user_id].to_i)
    if @user_score_info
      @user_plan = UserPlan.find_by_category_id_and_user_id(params[:category_id], cookies[:user_id])
      if @user_plan
        #显示计划列表
        @plan_list = @user_plan.get_plan_list
      else
        #生成初始的计划
        
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
