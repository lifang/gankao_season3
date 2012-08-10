class LearnController < ApplicationController
  layout nil
  require 'rexml/document'
  include REXML

  def get_plan
    plan = UserPlan.where(["user_id = ? and category_id = ?", 2, 2]).first
    xml = REXML::Document.new(File.open(plan.plan_url)) if plan
  end

  def word_step_one
    p get_plan
    respond_to do |format|
      format.js
    end
  end

  def word_step_sec

  end

  def word_step_thir

  end
  
end
