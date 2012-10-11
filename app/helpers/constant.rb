# encoding: utf-8
module Constant
  #项目文件目录
  PUBLIC_PATH = "#{Rails.root}/public"
  BACK_PUBLIC_PATH = "#{Rails.root}/public"

  WORD_TIME = {1 => 15, 2 => 15, 3 => 15}
  SENTENCE_TIME = {:READ => 1, :COMBIN => 2}
  LISTEN_TIME = {:PER => 1.5}
  READ_TIME = {:DEFAULT => 0.5, :QUESTION => 30}
  DICTATION = {:PRE => 10} # 听写
  TRANSLATE = {:ONE => 2, :TWO => 10} #翻译
  WRITE = {:PRE => 900}

  TOTAL_PATH = "http://gankao.co/"
  SERVER_PATH = "http://test.gankao.co"
  BACK_SERVER_PATH = "http://manage.gankao.co"
  GANKAO_GRADUATE_PATH = "http://pass.gankao.co/graduate"
  GANKAO_CET4_PATH = "http://pass.gankao.co/cet_four"
  GANKAO_CET6_PATH = "http://pass.gankao.co/cet_six"
  PAY_GRADUATE_PATH = "http://payky.gankao.co/"
  PAY_CET4_PATH = "http://paycet4.gankao.co/"
  PAY_CET6_PATH = "http://paycet6.gankao.co/"
  
  DEAD_LINE = {
    :CET4 => '2012-12-01',
    :CET6 => '2012-12-01',
    :GRADUATE => '2013-01-05'
  }
  #分享图片路径及大小
  IMG_NAME_SIZE="/share.png&width=500&height=385"
  SHARE_WORDS="用新版赶考网英语四级频道复习，四级必过，还免费的，太给力了，还有六级和考研频道，快来围观吧 http://www.gankao.co"
  QQ_WORDS="我正在使用新版赶考网复习，看起来不错，有四级、六级和考研英语，大家赶快来围观~~~"
  SUMMARY="新版赶考包括四级、六级和考研英语三个频道，有历年真题和详细解析，听力、词汇、阅读、写作资料齐全；最重要的是，新版赶考可以测试出你的当前英文水准，并基于此为你定制属于自己的复习计划，怎么样？很酷吧！"
  SHARE_IMG="share.png"
  QQ_IMG="100.jpg"
  COMMENT="新版赶考（http://www.gankao.co），非常给力！！"
  SHARE_TITLE="全新赶考网闪亮上线，英语在线备考从此无忧。"

  #  人人分享配置图片
  RENREN_IMG={:LOGIN=>{:type=>2,:ugc_id=>6525229578,:user_id=>600942099},2=>{:type=>2,:ugc_id=>6525711626,:user_id=>600942099},
    3=>{:type=>2,:ugc_id=>6525711625,:user_id=>600942099},4=>{:type=>2,:ugc_id=>6525711624,:user_id=>600942099}
  }


  RENREN_SHARE={2=>{:type=>2,:ugc_id=>6336084872,:user_id=>600942099},3=>{:type=>2,:ugc_id=>6336082558,:user_id=>601408987},
    4=>{:type=>2,:ugc_id=>6336077693,:user_id=>601411057}}

  #考试时间
  EXAM_DATE = {:CET4 => '2012-12-22', :CET6 => '2012-12-22', :GRADUATE => '2013-01-05'}

  DATE_LONG=90

  #四级路由
  CET4_PATH = "http://cet4.gankao.co"
  #六级路由
  CET6_PATH = "http://cet6.gankao.co"
  #考研路由
  GRADUATE_PATH = "http://graduate.gankao.co"
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