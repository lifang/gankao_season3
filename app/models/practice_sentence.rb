class PracticeSentence < ActiveRecord::Base
  belongs_to :category
  SENTENCE_MAX_LEVEL = {:CET4 => 10, :CET6 => 15, :GRADUATE => 20}
  LISTEN_MAX_LEVEL = {:CET4 => 50, :CET6 => 80}
  TRANSLATE_MAX_LEVEL = {:CET4 => 50, :CET6 => 80}
  DICTATION_MAX_LEVEL = {:CET4 => 50, :CET6 => 80}
end
