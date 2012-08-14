#encoding: utf-8
class SkillsController < ApplicationController
  layout 'main'
  def index
    category=params[:category_id].nil? ? 2 : params[:category_id]
    session[:pras]=nil
    types=(params[:con_t].nil? or params[:con_t].to_i>4) ? 1 : params[:con_t].to_i
    @skills=Skill.paginate_by_sql("select types,skill_title,skill_url,readed_num,s.created_at,name,simplify_con,s.id from skills s inner join
    users u on u.id=s.user_id where category_id=#{category} and s.types=#{types} order by readed_num desc",:per_page => 3, :page => params[:page])
  end


  def create
    cookies[:user_id]=1
    paras={:user_id=>cookies[:user_id],:skill_title=>params[:title],:category_id=>params[:category_id],:created_at=>Time.now,
      :simplify_con=>params[:text_con].strip[0..100].gsub("/r/n",""),:types=>params[:blog_types]}
    skill=Skill.create!(paras)
    skill.update_attributes(:skill_url=>"/skills/#{skill.category_id}/#{skill.id}.xml")
    Skill.write_xml("/skills/#{skill.category_id}","/#{skill.id}.xml",params[:text_con].strip)
    redirect_to "/skills?category_id=#{params[:category_id]}&con_t=#{params[:blog_types]}"
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
    category=params[:category_id].nil? ? 2 : params[:category_id]
    session[:pras]=nil
    session[:pras]=params[:search_con]
    redirect_to "/skills/search_result?category_id=#{category}&con_t=0"
  end

  def search_result
    @skills=Skill.paginate_by_sql("select types,skill_title,skill_url,readed_num,s.created_at,name,simplify_con,s.id from skills s inner join
    users u on u.id=s.user_id where category_id=#{params[:category_id]} and skill_title like '%#{session[:pras]}%' order by readed_num desc",:per_page => 3, :page => params[:page])
    render :index
  end

end
