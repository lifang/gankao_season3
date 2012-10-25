#encoding: utf-8
class SkillsController < ApplicationController
  include SkillsHelper
  layout 'main'
  before_filter :sign?, :only => ["create"]
  
  def index
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category]
    session[:pras]=nil
    @types=(params[:con_t].nil? or params[:con_t].to_i>4) ? 0 : params[:con_t].to_i
    @skills=Skill.paginate_by_sql("select types, skill_title, skill_url, readed_num, s.created_at,
    name, simplify_con, s.id from skills s inner join
    users u on u.id=s.user_id where category_id=#{category} 
    and s.status=#{Skill::PASS[:YES]} and s.types=#{@types}
    order by readed_num desc",:per_page => 10, :page => params[:page])
  end


  def create
    paras={:user_id=>cookies[:user_id],:skill_title=>params[:title],:category_id=>params[:category],:created_at=>Time.now,
      :simplify_con=>params[:text_con].strip[0..100].gsub("/r/n",""),:types=>params[:blog_types]}
    skill=Skill.create!(paras)
    skill.update_attributes(:skill_url=>"/skills_xml/#{skill.category_id}/#{skill.id}.xml")
    Skill.write_xml("/skills_xml/#{skill.category_id}","/#{skill.id}.xml",params[:text_con].strip)
    flash[:notice]="发表成功，等待审核"
    redirect_to "/skills?category=#{params[:category]}&con_t=#{params[:blog_types]}"
  end

  def show
    @skill=Skill.find(params[:id])
    @skill.update_attributes(:readed_num=>@skill.readed_num+1)
    @skill_infos=Skill.open_xml(@skill.skill_url).get_elements("/skill/next")
  end

  def like_blog
    Skill.find(params[:blog_id].to_i).update_attributes(:like_num=>params[:like_num])
    respond_to do |format|
      format.json {
        render :json=>"success"
      }
    end
  end

  def search_blog
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category]
    session[:pras]=nil
    session[:pras]=params[:search_con]
    redirect_to "/skills/search_result?category=#{category}&con_t=0"
  end

  def search_result
    @types=(params[:con_t].nil? or params[:con_t].to_i>4) ? 0 : params[:con_t].to_i
    @skills=Skill.paginate_by_sql("select types,skill_title,skill_url,readed_num,s.created_at,name,simplify_con,s.id from skills s inner join
    users u on u.id=s.user_id where category_id=#{params[:category]} and s.status=#{Skill::PASS[:YES]} and skill_title like '%#{session[:pras].strip}%' order by readed_num desc",:per_page => 4, :page => params[:page])
    @skills=Skill.paginate_by_sql("select types, skill_title, skill_url, readed_num,
    s.created_at,name,simplify_con,s.id from skills s inner join
    users u on u.id=s.user_id where category_id=#{params[:category]} 
    and s.status=#{Skill::PASS[:YES]} and skill_title like '%#{session[:pras].strip}%'
    order by readed_num desc",:per_page => 10, :page => params[:page])
    render :index
  end

   

end
