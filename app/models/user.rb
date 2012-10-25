# encoding: utf-8
class User < ActiveRecord::Base
  has_many :action_logs
  has_many :category_manages
  has_one :exam_user
  has_many :orders
  has_many :user_questions,:dependent=>:destroy
  has_many :question_answers,:dependent=>:destroy
  has_many :categories, :through=>:user_category_relations,:source => :category
  has_many :suns,:dependent=>:destroy
  DEFAULT_COVER = "/assets/u01.jpg"
  FROM = {"sina" => "新浪微博", "renren" => "人人网", "qq" => "腾讯网", "kaixin" => "开心网", "baidu" => "百度"}
  TIME_SORT = {:ASC => 0, :DESC => 1}   #用户列表按创建时间正序倒序排列
  U_FROM = {:WEB => 0, :APP => 1} #注册用户来源，0 网站   1 应用
  USER_FROM = {0 => "网站" , 1 => "应用"}

end
