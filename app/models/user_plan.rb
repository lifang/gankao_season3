# encoding: utf-8
class UserPlan < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  require 'rexml/document'
  include REXML

  def plan_list
    plan_list = self.plan_url
    file=File.open "#{Constant::PUBLIC_PATH}#{self.paper_url}"
    doc = Document.new(file)
    file.close
    
    
  end
end
