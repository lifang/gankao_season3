class WelcomeController < ApplicationController
  layout nil
  def index
   p UserPlan.calculate_user_plan_info(1, Category::TYPE[:CET4], 499, 0)  #求各个阶段花费时间 （单位：分钟）
   p UserPlan.package_level(Category::TYPE[:CET4])
  end

end
