class SkillsController < ApplicationController
  layout 'main'
  def index
    category=params[:category_id].nil? ? 2 : params[:category_id]
    skills=Skill.find_by_sql("select types,skill_title,skill_url from skills where category_id=#{category} order by created_at")
    @skills={}
    skills.each do |skill|
      if  @skills[skill.types].nil?
        @skills[skill.types]=[skill]
      else
        @skills[skill.types] << skill
      end
    end unless skills.blank?
  end

end
