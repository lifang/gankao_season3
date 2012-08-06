# encoding: utf-8
class Notice < ActiveRecord::Base
  belongs_to :category
  belongs_to :user, :foreign_key => "target_id"

end
