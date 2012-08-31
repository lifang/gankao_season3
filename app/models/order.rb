# encoding: utf-8
class Order < ActiveRecord::Base
  belongs_to :user

  STATUS = {:NOMAL => 1, :INVALIDATION => 0} #1 正常  0 失效
  TYPES = {:CHARGE => 0, :ACCREDIT => 1} #0 付费  1 授权码
  USER_ORDER = {:VIP => 0, :NOMAL => 1} #根据order类型和状态判断当前用户的情况：0 vip  1 普通用户

  PAY_TYPES = {:CHARGE => 1,:LICENSE=>2 }
  PAY_TYPE_NAME = {1 => "充值付费",2=>"授权码"}
  PAY_FEE={:CET4=>68,:CET6=>0.01,:GRADUATE=>0.01}
end
