# encoding: utf-8
class ExaminationPaperRelation< ActiveRecord::Base
  belongs_to :examination
  belongs_to :paper

end
