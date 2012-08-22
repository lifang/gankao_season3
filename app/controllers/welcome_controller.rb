#encoding: utf-8
class WelcomeController < ApplicationController
  layout nil
  def index
    #  p UserPlan.calculate_user_plan_info(2, Category::TYPE[:GRADUATE], 70)  #求各个阶段花费时间 （单位：分钟）
    p UserPlan.calculate_user_plan_info(1, Category::TYPE[:CET4], 500)  #求各个阶段花费时间 （单位：分钟）
    p UserPlan.package_level(Category::TYPE[:CET4])
  end

  
  #从应用快捷登录
  def renren
    category = params[:category].nil? ? "2" : params[:category]
    @user= User.find_by_id_and_code_id(params[:user_id],params[:code_id])
    if @user
      cookies[:user_name] ={:value =>@user.username, :path => "/", :secure  => false}
      cookies[:user_id] ={:value =>@user.id, :path => "/", :secure  => false}
      get_role
      redirect_to "/?category=#{category}"
    else
      render :inline=>"用户验证失败，为了保证用户的帐号安全，此次访问被系统拒绝。<a href='www.gankao.co'>将跳转到到首页</a>"
    end
  end
end
