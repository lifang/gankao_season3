# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  BACK_PUBLIC_PATH = "#{Rails.root}/public"

  WORD_TIME = {1 => 15, 2 => 15, 3 => 15}
  SENTENCE_TIME = {:READ => 1, :COMBIN => 2}
  LISTEN_TIME = {:PER => 1.5}
  READ_TIME = {:DEFAULT => 0.5, :QUESTION => 30}

  SERVER_PATH = "http://localhost:3001"
  BACK_SERVER_PATH = "http://localhost:3000"

  GANKAO_GRADUATE_PATH = "http://localhost:3000/graduate"
  GANKAO_CET4_PATH = "http://localhost:3000/cet_four"
  GANKAO_CET6_PATH = "http://localhost:3000/cet_six"

  #根据设定的日期判断用户的学习周期
  DEAD_LINE = {
    :CET4 => '2012-11-15',
    :CET6 => '2012-10-15',
    :GRADUATE => '2013-01-05'
  }
  #分享图片路径及大小
  IMG_NAME_SIZE="/gankao_share.png&width=500&height=385"
  SHARE_WORDS="我正在使用新版赶考网(http://www.gankao.co)复习，看起来不错，有四级、六级和考研英语，大家赶快来围观~~~"

  RENREN_IMG="/gankao_share.png"


  #考试时间
  EXAM_DATE = {:CET4 => '2012-12-22', :CET6 => '2012-12-22', :GRADUATE => '2013-01-05'}

  DATE_LONG=90

  #四级路由
  CET4_PATH = "http://cet4.gankao.co/"
  #六级路由
  CET6_PATH = "http://cet4.gankao.co/"
  #考研路由
  GRADUATE_PATH = "http://graduate.gankao.co/"
  #快捷方式路由
  FAST_PATH = {
    2 => ["英语四级频道", "#{SERVER_PATH}/CET4.url"],
    3 => ["英语四级频道", "#{SERVER_PATH}/CET6.url"],
    4 => ["英语考研频道", "#{SERVER_PATH}/KAOYAN.url"]
  }

  #游动文字
  SCOLL_WORD = {
    2 => "英语四级保过",
    3 => "英语六级保过",
    4 => "考研英语不低于55分",
  }
end