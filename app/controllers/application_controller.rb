class ApplicationController < ActionController::Base
  protect_from_forgery
  include Constant
  include ApplicationHelper
  before_filter :judge_url

  def judge_url
    if request.host_with_port == Constant::CET4_PATH
      redirect_to Constant::SERVER_PATH + "plans?category=#{Category::TYPE[:CET4]}"
    elsif request.host_with_port == Constant::CET6_PATH
      redirect_to Constant::SERVER_PATH + "plans?category=#{Category::TYPE[:CET6]}"
    elsif request.host_with_port == Constant::GRADUATE_PATH
        redirect_to Constant::SERVER_PATH + "plans?category=#{Category::TYPE[:GRADUATE]}"
    end
  end
end
