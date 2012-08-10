#encoding: utf-8
class SkillsController < ApplicationController
  layout 'main'
  def index
    category=params[:category_id].nil? ? 2 : params[:category_id]
    types=(params[:con_t].nil? or params[:con_t].to_i>4) ? 1 : params[:con_t].to_i
    @skills=Skill.paginate_by_sql("select types,skill_title,skill_url,readed_num,s.created_at,name,simplify_con from skills s inner join
    users u on u.id=s.user_id where category_id=#{category} and s.types=#{types} order by readed_num",:per_page => 2, :page => params[:page])
  end


  def create
    cookies[:user_id]=1
    paras={:user_id=>cookies[:user_id],:skill_title=>params[:title],:category_id=>params[:category_id],:created_at=>Time.now,
      :simplify_con=>params[:text_con].strip[0..100].gsub("/r/n",""),:types=>params[:blog_types]}
    skill=Skill.create!(paras)
    skill.update_attributes(:skill_url=>"/skills/#{skill.category_id}/#{skill.id}.xml")
    Skill.write_xml("/skills/#{skill.category_id}","/#{skill.id}.xml",params[:text_con].strip)
    redirect_to "/skills"
  end

end
