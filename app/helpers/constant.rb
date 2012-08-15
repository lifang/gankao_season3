# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  
  WORD_TIME = {1 => 15, 2 => 15, 3 => 15}
  SENTENCE_TIME = {1 => 10, 2 => 20, 3 => 20}
  
  DEAD_LINE = {
    :CET4 => '2012-9-12',
    :CET6 => '2012-10-7',
    :GRADUATE => '2012-10-7'
  }
end