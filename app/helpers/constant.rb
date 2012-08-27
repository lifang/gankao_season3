# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  
  WORD_TIME = {1 => 15, 2 => 15, 3 => 15}
  SENTENCE_TIME = {:READ => 1, :COMBIN => 2}
  LISTEN_TIME = {:PER => 1.5}
  READ_TIME = {:DEFAULT => 0.5, :QUESTION => 30}
  
  SERVER_PATH = "http://localhost:3001"
  GANKAO_GRADUATE_PATH = "http://localhost:3000/graduate"
  GANKAO_CET4_PATH = "http://localhost:3000/cet_four"
  GANKAO_CET6_PATH = "http://localhost:3000/cet_six"
  DEAD_LINE = {
    :CET4 => '2012-9-12',
    :CET6 => '2012-10-7',
    :GRADUATE => '2013-01-12'
  }
  DATE_LONG=90
  
end