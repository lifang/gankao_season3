class Sun < ActiveRecord::Base
  belongs_to :user

  TYPES = {:FIRSTLOGIN => 0, :TEST => 1, :SIGNIN => 2, :SINASHARE => 3,:RENRENSHARE => 4 ,:KEEP_ON_LOGIN =>5,
    :RANDOM_AWARD => 6, :COMMEND => 7, :ANSWER => 8, :LOGIN_MORE=>9} #0首次登陆 1前测 2签到 3新浪微博分享 4人人分享 5连续登录 6 随机奖励 7 推荐 8答疑
  TYPE_NUM = {:FIRSTLOGIN => 1, :GRADUATE_TEST => 14, :CET_TEST => 4, :SIGNIN => 1, :SHARE => 2,
    :KEEP_ON_LOGIN => 1, :RANDOM_AWARD => 2, :COMMEND => 5, :ANSWER => 2,:LOGIN_MORE=>5}


  default_scope order: 'suns.created_at DESC'

  #完成前测增加小太阳
  def self.complete_test(category_id, user_id)
    sun_num = category_id == Category::TYPE[:GRADUATE] ? TYPE_NUM[:GRADUATE_TEST] : TYPE_NUM[:CET_TEST]
    self.create(:category_id => category_id, :user_id => user_id, :types => TYPES[:TEST], :num => sun_num)
  end

end
