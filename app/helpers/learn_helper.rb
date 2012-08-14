module LearnHelper

  #听写过程
  #从xml里读出数据后从数据库中取出
  def listen_write_source(xml)
    #复习的句子
    review_listen_sentences=[]
    #复习个数
    review_sum=0
    listen_s=xml.get_elements("") #获取复习听的句子
    review_listen_sentences= (review_listen_sentences<<listen_s).flatten
    review_sum=review_listen_sentences.length

    recite_listen_sentences = xml.get_elements("")#新学
    recite_sum = recite_listen_sentences.length #新学听写总数

    if review_sum>0
      #获取第一个复习的听写句子
      xml_sentence,web_type=review_listen_sentences[0],"review"
    else
      if recite_sum > 0
        #获取第一个新学的听写句子
        xml_sentence,web_type = recite_listen_sentences[0],"recite"
      else
        return nil
      end
    end

    listen_sentence=PracticeSentence.find(xml_sentence.attributes["id"])
    step = xml_sentence.attributes["step"]

    return {:listen_sentence=>listen_sentence,:web_type=>web_type,:step=>step}
  end
end
