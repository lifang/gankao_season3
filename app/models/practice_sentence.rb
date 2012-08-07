class PracticeSentence < ActiveRecord::Base
  belongs_to :category
  TYPES = {:SENTENCE => 0, :LINSTEN => 1, :TRANSLATE => 2, :DICTATION => 3} #0 句子  1 听力  2 翻译  3 听写
end
