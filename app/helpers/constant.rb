# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  
  WORD_TIME = {1 => 15, 2 => 15, 3 => 15}
  SENTENCE_TIME = {:READ => 1, :COMBIN => 2}
  LISTEN_TIME = {:PER => 1.5}
  
  SERVER_PATH = "http://localhost:3000"
  DEAD_LINE = {
    :CET4 => '2012-9-12',
    :CET6 => '2012-10-7',
    :GRADUATE => '2012-10-7'
  }

  #新浪微博应用信息 gankao@hotmail.com  comdosoft2011
  SINA_CLIENT_ID = "3987186573"

  #人人应用信息  wangguanhong@hotmail.com  comdo2010
  RENREN_CLIENT_ID = "182012"
  RENREN_API_KEY = "98a6ed88bccc409da12a8abe3ebec3c5"
  RENREN_API_SECRET = "0d19833c0bc34a27a58786c07ef8d9fb"

end