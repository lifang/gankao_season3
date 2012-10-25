#encoding: utf-8
class Word < ActiveRecord::Base
  belongs_to :category
  has_many :word_sentences

  TYPES = {0 => "n.", 1 => "v.", 2 => "pron.", 3 => "adj.", 4 => "adv.",
    5 => "num.", 6 => "art.", 7 => "prep.", 8 => "conj.", 9 => "interj.", 10 => "u = ", 11 => "c = ", 12 => "pl = "}
  #英语单词词性 名词 动词 代词 形容词 副词 数词 冠词 介词 连词 感叹词 不可数名词 可数名词 复数
  MAX_LEVEL = {:CET4 => 50, :CET6 => 66, :GRADUATE => 78}
  
  #根据 等级、类型 随机抽取N条单词
  def Word.get_words_by_level(level, limit, except)
    return Word.find_by_sql([
      "select t.* from words t where t.id != ? and t.level = ? order by rand() limit ?",
      except, level, limit])
  end
end
