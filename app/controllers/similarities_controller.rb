#encoding: utf-8
class SimilaritiesController < ApplicationController
  layout 'main'
  before_filter :sign?, :except => "index"
  
  def index
    category_id = "#{params[:category]}"=="" ? 2 : params[:category]
    @category = Category.find_by_id(category_id.to_i)
    
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
  end

  def join
    category_id = params[:category].nil? ? 2 : params[:category]
    similarity = Examination.find(params[:id])
    #设置考试试卷
    papers_arr=[]
    similarity.papers.each do |paper|
      papers_arr << paper
    end
    if papers_arr.length>0
      @paper = papers_arr.sample
      @exam_user = ExamUser.find(:first,
        :conditions => ["paper_id = ? and p_types = ? and examination_id = ? and user_id = ?",
          @paper.id, ExamUser::P_TYPES[:ZHENTI], params[:id], cookies[:user_id]])
      @exam_user = ExamUser.create(:user_id => cookies[:user_id], :examination_id => params[:id],
        :paper_id => @paper.id) if @exam_user.nil?
      redirect_to "/exam_users/#{@exam_user.id}?category=#{category_id}&type=similarities"
    else
      flash[:share_notice]="当前考试未指定试卷。"
      redirect_to "/similarities?category=#{category_id}"
    end
  end

end
