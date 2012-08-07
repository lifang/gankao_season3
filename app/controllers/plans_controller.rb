class PlansController < ApplicationController
  layout 'main'
  
  def index
    cookies[:user_id] = 1  #登录做完之后要删除
    user_score_info = UserScoreInfo.find_by_category_id_and_user_id(params[:category_id].to_i, cookies[:user_id].to_i)
    if user_score_info
      user_plan = UserPlan.find_by_category_id_and_user_id(params[:category_id], cookies[:user_id])
      if user_plan
        #显示计划列表


      else
        #生成初始的计划
      end
    end    
  end

end
