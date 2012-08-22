# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  
  WORD_TIME = {1 => 15, 2 => 15, 3 => 15}
  SENTENCE_TIME = {:READ => 1, :COMBIN => 2, :RMIN => 10,:CMIN => 20, :MAX => 60}
  LISTEN_TIME = {:PER => 1.5, :MIN => 15, :MAX => 30}
  
  SERVER_PATH = "http://localhost:3000"
  DEAD_LINE = {
    :CET4 => '2012-9-12',
    :CET6 => '2012-10-7',
    :GRADUATE => '2012-10-7'
  }
  DATE_LONG=90
end