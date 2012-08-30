class Sun < ActiveRecord::Base
  require 'rexml/document'
  include REXML

  belongs_to :user

  TYPES = {:FIRSTLOGIN => 0, :TEST => 1, :SIGNIN => 2, :SINASHARE => 3,:RENRENSHARE => 4 ,:KEEP_ON_LOGIN =>5,
    :RANDOM_AWARD => 6, :COMMEND => 7, :ANSWER => 8, :LOGIN_MORE=>9,:QQSHARE=>10,:OPEN_CET4=>11,:OPEN_CET6=>12,
    :OPEN_KAOYAN=>13} #0首次登陆 1前测 2签到 3新浪微博分享 4人人分享 5连续登录 6 随机奖励 7 推荐 8答疑
  TYPE_NUM = {:FIRSTLOGIN => 1, :GRADUATE_TEST => 14, :CET_TEST => 4, :SIGNIN => 1, :SHARE => 2,
    :KEEP_ON_LOGIN => 1, :RANDOM_AWARD => 2, :COMMEND => 5, :ANSWER => 2,:LOGIN_MORE=>5,:CET=>-3,:KAOYAN=>-8}


  default_scope order: 'suns.created_at DESC'

  #完成前测增加小太阳
  def self.complete_test(category_id, user_id)
    sun_num = category_id == Category::TYPE[:GRADUATE] ? TYPE_NUM[:GRADUATE_TEST] : TYPE_NUM[:CET_TEST]
    self.create(:category_id => category_id, :user_id => user_id, :types => TYPES[:TEST], :num => sun_num)
  end

  #首次登录
  def self.first_login(user_id)
    self.create(:category_id => Category::TYPE[:CET4], :user_id => user_id,
      :types => TYPES[:FIRSTLOGIN], :num => TYPE_NUM[:FIRSTLOGIN])
    self.create(:category_id => Category::TYPE[:CET6], :user_id => user_id,
      :types => TYPES[:FIRSTLOGIN], :num => TYPE_NUM[:FIRSTLOGIN])
    self.create(:category_id => Category::TYPE[:GRADUATE], :user_id => user_id,
      :types => TYPES[:FIRSTLOGIN], :num => TYPE_NUM[:FIRSTLOGIN])
  end

  #打开任务包-扣小太阳数
  def self.open_package(user_id,category, xml)
    #获取用户当前类别下的总太阳数
    sun=Sun.find_by_sql("select ifnull(sum(num), 0) num from suns where category_id=#{category} and user_id=#{user_id}")[0]
    total_suns= sun.nil? ? 0 : sun.num.to_i
    has_suns = false
    if category==Category::TYPE[:GRADUATE]
      if total_suns + TYPE_NUM[:KAOYAN] >= 0
        count=Sun.count_by_sql("select count(id) open_count from suns
        where category_id=#{category} and user_id=#{user_id} and types=#{TYPES[:KAOYAN]}")
        has_suns = true
      end
    else
      if total_suns + TYPE_NUM[:CET] >= 0
        if category==Category::TYPE[:CET4]
          count=Sun.count_by_sql("select count(id) open_count from suns
        where category_id=#{category} and user_id=#{user_id} and types=#{TYPES[:OPEN_CET4]}")
        else
          count=Sun.count_by_sql("select count(id) open_count from suns
        where category_id=#{category} and user_id=#{user_id} and types=#{TYPES[:OPEN_CET6]}")
        end
        has_suns = true
      end    
    end
    if has_suns
      current = xml.elements["root/plan/current"].text.to_i
      if current > count
        if category == Category::TYPE[:CET4]
          self.create(:category_id => category, :user_id => user_id,
            :types => TYPES[:OPEN_CET4], :num => TYPE_NUM[:CET])
        elsif category == Category::TYPE[:CET6]
          self.create(:category_id => category, :user_id => user_id,
            :types => TYPES[:OPEN_CET6], :num => TYPE_NUM[:CET])
        else
          self.create(:category_id => category, :user_id => user_id,
            :types => TYPES[:OPEN_KAOYAN], :num => TYPE_NUM[:KAOYAN])
        end
      end
    end
    return has_suns
  end

end
