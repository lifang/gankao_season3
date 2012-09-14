# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  BACK_PUBLIC_PATH = "#{Rails.root}/public"

  WORD_TIME = {1 => 15, 2 => 15, 3 => 30}
  SENTENCE_TIME = {:READ => 1, :COMBIN => 3}
  LISTEN_TIME = {:PER => 1.5}
  READ_TIME = {:DEFAULT => 0.5, :QUESTION => 30}

  TOTAL_PATH = "gankao.co"
  SERVER_PATH = "http://localhost:3001"
  BACK_SERVER_PATH = "http://manage.gankao.co"

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

  #通栏url
  TAOBAO_URL = {
    2 => ["四级：亚马逊提供最全四级复习参考资料，更有超低价的开学特惠专区",
      "http://s.click.taobao.com/t_11?e=%2BtSC5ziSlHJDn0pr%2F9njawAmde2OYPBcsA40bHP9WXzM5l7ADIqa9j15g63WZyiOeIAcouggP%2BknP8NA%2BKI%2F7RKFKdxFsMSktAW9ToqRp5KWvvkPws5oagfkIt%2Bvy08XVmzKXy73q3ynBEAHlraQ%2FVNEgotWKi0xnCgxuYergB8b1fX452DIPT2ZplRLxQ9jEZwAgtkzKBwvisnRpY1uuto%2ByZNts1S6GqUkSSxj45wf%2BoqZiU69trWr8si0BNMnTnugFefO6VP6pPxbDCNvghwHoN5HFT7SYv6nh%2BXNXxPToo0Pe8b7w1AC2wLehLlu8XCozADMiuO6JgZa7Gc%3D&p=mm_32461315_3337046_10827937"],
    3 => ["六级：亚马逊提供最全六级复习参考资料，更有超低价的开学特惠专区",
      "http://s.click.taobao.com/t_11?e=%2BtSC5ziSlHJDn0pr%2F9njawAmde2OYPBcsA40bHP9WXzM5l7ADIqa9j15g63WZyiOeIAcouggP%2BknP8NA%2BKI%2F7RKFKd%2FJw4%2BYbQ18gWZSLaXeP%2F8R4nV8pEuyuwUa2vnYe4Aufz%2FEkR2jJ6uHQteR9Dj5YkeBzAVYNC2DBxJC51Pg1CsbYyJHr8gtdF0b%2BwCqQfPYOtIcmWROEDyuRFlveSVozf5Zz0Ixy%2F20Q7nxz9nF5f%2FVNPn0ah9rrmmPQwnlZAQRryB8md7zddGt6LcWIK5oAaZzepWOsAStYpi7qL9w0bI4I1lCKJJ6lRgRGgMsDHWvF%2FWEYsCsnjt8aAk%3D&p=mm_32461315_3337046_10828645"],
    4 => ["考研：亚马逊提供最全考研复习参考资料，更有超低价的开学特惠专区",
      "http://s.click.taobao.com/t_11?e=%2BtSC5ziSlHJDn0pr%2F9njawAmde2OYPBcsA40bHP9WXzM5l7ADIqa9j15g63WZyiOeIAcouggP%2BknP8NA%2BKI%2F7RKFKd%2FJw4%2BYbQ18gWZSLaXeP%2F8R4nV8pEuyuwUa2vnYe4Aufz%2FEkR2jJ6uHQteR9Dj5YkeBzAVYNC2DBxJC51Pg1CsbYyJHr8gtdF0b%2BwCqQfPYOtIcmWROEDyuRFlveSVozf5Zz0Ixy%2F20Q7nxz9nF5f%2FVNPn0ah9rrmmPQwnlZAQRryB8md7zddGt6LcWIK5oAaZzepWOsAStYpi7qL9w0bI4I1lCKJJ6lRgRGgMsDHWvF%2FWEYsCsnjt8aAmEbHDwL93K%2BhVJPiygx2kvJi%2FjQ9A0uClPKqXZyY3aaCqNgwDqsb1wtdQl%2FV%2F8eOM8IuAFvxBTlXzYDF3z%2FBTRrPz6gY2Grw4PcT6Tkd07%2F3VNpnGorIr52U1CJcAUtr1SlRqwKCGy5sZ0YK3F8FAdxXHRq8vI3bNyoQ6dL1MNpYoZDQ2HM4xevREpULFmhSXoSs7ZK%2Fnk8n2inz4UliN4QsNhWHRUIYj%2Ft1CEr%2BAZdR3wKNp59MNySeWYsc617%2B4bvMyWRNSwW4ozAYC%2FXRt5otC%2B9OH0lsc8H5fyhQhbMQgofQSAxDtG9odFD2IwoxwZfD%2BM0J9WfO93X5c%3D&p=mm_32461315_3337046_10828658"]
  }
end