#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  include Constant
  include ApplicationHelper
  before_filter :judge_url

  def judge_url
    if request.url == Constant::CET4_PATH
      redirect_to Constant::SERVER_PATH + "/plans?category=#{Category::TYPE[:CET4]}"
    elsif request.url == Constant::CET6_PATH
      redirect_to Constant::SERVER_PATH + "/plans?category=#{Category::TYPE[:CET6]}"
    elsif request.url == Constant::GRADUATE_PATH
      redirect_to Constant::SERVER_PATH + "/plans?category=#{Category::TYPE[:GRADUATE]}"
    elsif request.url == Constant::TOTAL_PATH
      redirect_to Constant::SERVER_PATH
    elsif request.url == Constant::PAY_GRADUATE_PATH
      redirect_to Constant::SERVER_PATH + "/pay?category=#{Category::TYPE[:GRADUATE]}"
    elsif request.url == Constant::PAY_CET4_PATH
      redirect_to Constant::SERVER_PATH + "/pay?category=#{Category::TYPE[:CET4]}"
    elsif request.url == Constant::PAY_CET6_PATH
      redirect_to Constant::SERVER_PATH + "/pay?category=#{Category::TYPE[:CET6]}"
    elsif request.url == Constant::IPAD_GRADUATE_PATH
      redirect_to Constant::SERVER_PATH + "/plans?category=#{Category::TYPE[:GRADUATE]}&ipad=1"
    elsif request.url == Constant::IPAD_CET4_PATH
      redirect_to Constant::SERVER_PATH + "/plans?category=#{Category::TYPE[:CET4]}&ipad=1"
    elsif request.url == Constant::IPAD_CET6_PATH
      redirect_to Constant::SERVER_PATH + "/plans?category=#{Category::TYPE[:CET6]}&ipad=1"
    end
  end
end
