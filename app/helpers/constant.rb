# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"

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
    :CET4 => '2012-12-01',
    :CET6 => '2012-12-01',
    :GRADUATE => '2013-01-05'
  }

  #考试时间
  EXAM_DATE = {:CET4 => '2012-12-22', :CET6 => '2012-12-22', :GRADUATE => '2013-01-05'}

  DATE_LONG=90

end