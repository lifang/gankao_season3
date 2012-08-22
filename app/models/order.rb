# encoding: utf-8
class Order < ActiveRecord::Base
  belongs_to :user

  STATUS = {:NOMAL => 1, :INVALIDATION => 0} #1 正常  0 失效
  TYPES={:VIP=>1,:NOMAL=>0}
  PAY_TYPES = {:CHARGE => 1,:LICENSE=>2 }
  PAY_TYPE_NAME = {1 => "充值付费",2=>"授权码"}
  PAY_FEE={:CET4=>68,:CET6=>68,:GRADUATE=>680}
end
