class WelcomeController < ApplicationController
  layout nil
  def index

    p u = UserPlan.target_level_report(365, "CET4")
    p UserPlan.calculate_user_plan_times(1, u)
#    p UserPlan.target_level_report(30, "GRADUATE")
#    p UserPlan.target_level_report(30, "CET6")
#    p UserPlan.target_level_report(30, "CET4")
#    p UserPlan.target_level_report(110, "CET4")
#    p UserPlan.target_level_report(370, "CET4")
#    p UserPlan.target_level_report(440, "CET4")
#    p UserPlan.target_level_report(500, "CET4")
  end

end
