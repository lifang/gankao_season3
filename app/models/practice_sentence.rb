class PracticeSentence < ActiveRecord::Base
  belongs_to :category
  TYPES = {:SENTENCE => 0, :LINSTEN => 1, :TRANSLATE => 2, :DICTATION => 3} #0 句子  1 听力  2 翻译  3 听写
  SENTENCE_MAX_LEVEL = {:CET4 => 10, :CET6 => 15, :GRADUATE => 20}
  LISTEN_MAX_LEVEL = {:CET4 => 50, :CET6 => 90}
  TRANSLATE_MAX_LEVEL = {:CET4 => 50, :CET6 => 90}
  DICTATION_MAX_LEVEL = {:CET4 => 50, :CET6 => 90}

  def self.get_listen_by_level(level, category, types, limit, except)
    return Word.find_by_sql([
        "select t.* from practice_sentences t where t.id != ? and t.level = ? and t.category_id = ? and t.types = ? order by rand() limit ?",
        except, level, category, types, limit])
  end
end
