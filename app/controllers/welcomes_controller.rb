#encoding: utf-8
class WelcomesController < ApplicationController
 
  def index
    render :layout => false
  end

  def fast_icon
    
  end

  def handdrives
    @category = Category.find(Category::TYPE[:HANDDRIVE])
    sql = "select e.id, e.title, e.is_free from examinations e
        where e.category_id = #{@category.id} and e.types = #{Examination::TYPES[:OLD_EXAM]}"
    if !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:YES].to_s
      sql += " and e.is_free = #{Examination::IS_FREE[:YES]}"
    elsif !params[:category_type].nil? and params[:category_type] == Examination::IS_FREE[:NO].to_s
      sql += " and (e.is_free = #{Examination::IS_FREE[:NO]} or e.is_free is null)"
    end
    @similarities = Examination.paginate_by_sql(sql,
      :per_page => 10, :page => params[:page])
    if cookies[:user_id]
      examination_ids = []
      @exam_user_hash = {}
      @similarities.each { |sim| examination_ids << sim.id }
      @exam_users = ExamUser.find_by_sql(["select eu.id, eu.examination_id, eu.is_submited,eu.p_types,
      eu.answer_sheet_url from exam_users eu where eu.user_id = ?
      and eu.examination_id in (?)", cookies[:user_id].to_i, examination_ids])
      @exam_users.each { |eu|
        if @exam_user_hash[eu.examination_id].nil?
          @exam_user_hash[eu.examination_id] ={eu.p_types=>[eu.id,eu.is_submited,eu.answer_sheet_url] }
        else
          @exam_user_hash[eu.examination_id][eu.p_types]=[eu.id,eu.is_submited,eu.answer_sheet_url]
        end
      }
    end
    render :layout => false
  end

  def check_exercise
    #yes=false
    #exam_users=ExamUser.find_by_sql("select * from exam_users eu inner join examinations e on eu.examination_id=e.id
    #  where e.category_id=#{Category::TYPE[:HANDDRIVE]} and eu.user_id=#{cookies[:user_id]}")
    #yes=true if  exam_users.blank?  || exam_users.inject(Array.new) { |arr, a| arr.push(a.examination_id) }.include?(params[:sim].to_i)
    #yes=true     if Order.find_by_user_id_and_category_id(cookies[:user_id],Category::TYPE[:HANDDRIVE])
    #if yes
      if (params[:types].to_i == ExamUser::P_TYPES[:MOKAO])
        redirect_to "/simulations/#{params[:sim]}/do_exam?category=#{params[:category]}"
      elsif (params[:types].to_i == ExamUser::P_TYPES[:ZHENTI] )
        redirect_to  "/similarities/#{params[:sim]}/join?category=#{params[:category]}"
      end
    #else
      #cookies[:is_ckecked]=1
      #redirect_to "/welcomes/handdrives?category=#{params[:category]}"
    #end
  end

end
