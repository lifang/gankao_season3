class WelcomeController < ApplicationController
  layout nil
  def index

    p u = UserPlan.target_level_report(365, "CET4")
    p UserPlan.calculate_user_plan_times(1, u)
    p UserPlan.package_level("CET4")
  end

end
