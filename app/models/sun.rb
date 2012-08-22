class Sun < ActiveRecord::Base
  belongs_to :user

  TYPES = {:FIRSTLOGIN => 0, :TEST => 1, :SIGNIN => 2, :SHARE => 3, :KEEP_ON_LOGIN => 4,
    :RANDOM_AWARD => 5, :COMMEND => 6, :ANSWER => 7} #0首次登陆 1前测 2签到 3分享 4连续登录 5 随机奖励 6 推荐 7 答疑
  TYPE_NUM = {:FIRSTLOGIN => 1, :GRADUATE_TEST => 14, :CET_TEST => 4, :SIGNIN => 1, :SHARE => 2,
    :KEEP_ON_LOGIN => 1, :RANDOM_AWARD => 2, :COMMEND => 5, :ANSWER => 2}

  #完成前测增加小太阳
  def self.complete_test(category_id, user_id)
    sun_num = category_id == Category::TYPE[:GRADUATE] ? TYPE_NUM[:GRADUATE_TEST] : TYPE_NUM[:CET_TEST]
    self.create(:category_id => category_id, :user_id => user_id, :types => TYPES[:TEST], :num => sun_num)
  end

end
