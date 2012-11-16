#encoding: utf-8
class ExamRatersController < ApplicationController
  layout 'rater'

  def rater_session #阅卷老师登陆页面
    @rater=ExamRater.find(:first,:conditions =>["id = #{params[:id].to_i} and examination_id = #{params[:examination].to_i}"])
    if @rater.nil?
      render :inline=>"您访问的页面不存在。"
    else
      @examination=Examination.find(params[:examination])
      render "/exam_raters/session"
    end
  end

  def rater_login  #阅卷老师登陆
    @rater=ExamRater.find(params[:id])
    @examination=Examination.find(params[:examination_id])
    if @rater.author_code==params[:author_code]
      cookies[:rater_id]={:value =>@rater.id, :path => "/", :secure  => false}
      cookies[:rater_name]={:value =>@rater.name, :path => "/", :secure  => false}
      flash[:success]="登陆成功"
      redirect_to  "/exam_raters/#{params[:examination_id]}/reader_papers?rater_id=#{@rater.id}"
    else
      flash[:error]="阅卷码不正确，请核对！"
      render "/exam_raters/session"
    end
  end

  def reader_papers  #答卷批阅状态显示
    auth_rater=ExamRater.find(:first,:conditions =>["id = #{cookies[:rater_id].to_i} and examination_id = #{params[:id].to_i}"])
    if auth_rater.nil?
      redirect_to "/exam_raters/#{params[:rater_id]}/rater_session?examination=#{params[:id]}"
    else
      @examination=Examination.find(params[:id].to_i)
      @user=User.find(@examination.creater_id)
      @exam_paper_total =ExamRater.get_paper(params[:id].to_i)
      @exam_score_total =0
      @exam_paper_marked =0
      @marked_now=0
      @rater_id=cookies[:rater_id]
      @exam_paper_total.each do |e|
        @marked_now +=1 if e.exam_rater_id==cookies[:rater_id].to_i and e.is_marked!=1
        @exam_score_total +=1 unless e.relation_id
        @exam_paper_marked +=1 if e.is_marked==1
      end unless @exam_paper_total.blank?
    end
  end

  def check_paper  #选择要批阅的答卷
    @exam_user=RaterUserRelation.find_by_sql("select * from rater_user_relations
      where exam_rater_id=#{cookies[:rater_id].to_i} and is_marked=#{RaterUserRelation::IS_MARKED[:NO]}")
    if @exam_user.blank?||@exam_user==[]
      examination=params[:examination_id].to_i
      @exam_user= ExamUser.find_by_sql("select eu.id from exam_users eu left join rater_user_relations r
        on r.exam_user_id = eu.id inner join orders o on o.user_id = eu.user_id 
        inner join examinations ex on ex.id = eu.examination_id
        where eu.answer_sheet_url is not null and
        eu.is_submited=#{ExamUser::IS_SUBMITED[:YES]} and eu.examination_id = #{examination}
        and o.category_id = ex.category_id and
        o.types in (#{Order::TYPES[:CHARGE]},#{Order::TYPES[:ACCREDIT]})        
        and o.status=#{Order::STATUS[:NOMAL]} and r.exam_user_id is null order by rand() limit 1")
      id=@exam_user[0].id
    else
      id=@exam_user[0].exam_user_id
    end
    unless @exam_user.blank?
      redirect_to "/exam_raters/#{id}/answer_paper?rater_id=#{cookies[:rater_id]}"
    else
      flash[:notice] = "当场考试试卷已经全部阅完。"
      redirect_to request.referer
    end
  end

  def answer_paper #批阅答卷
    @exam_user=ExamUser.find(params[:id])
    if @exam_user.nil?
      render :inline=>"您访问的页面不存在。"
    else
      doc=open_file(Constant::PUBLIC_PATH + @exam_user.answer_sheet_url)
      xml=open_file(Constant::BACK_PUBLIC_PATH + @exam_user.paper.paper_url)
      @xml=ExamRater.answer_questions(xml,doc)
      @reading= RaterUserRelation.find(:first, 
        :conditions => ["exam_rater_id=#{cookies[:rater_id]}
          and is_marked=#{RaterUserRelation::IS_MARKED[:NO]} and exam_user_id=#{@exam_user.id}"])
      if @xml[0].blank?
        flash[:notice] = "感谢您的参与，当前试卷没有需要批改的试卷。"
      else
        if @reading.nil?
          @reading=RaterUserRelation.create(:exam_rater_id => cookies[:rater_id],
            :exam_user_id => @exam_user.id, :started_at =>Time.now,:is_marked=>RaterUserRelation::IS_MARKED[:NO])
        end
      end
    end
  end

  def over_answer #批阅完成，给答卷添加成绩
    score_reason=params[:score_reason]
    @exam_relation=RaterUserRelation.find(params[:id])
    @exam_relation.update_attributes(:rate_time=>((Time.now-@exam_relation.started_at)/60+1).to_i)
    @exam_user=ExamUser.find(@exam_relation.exam_user_id)
    begin
      url="#{Rails.root}/public#{@exam_user.answer_sheet_url}"
      doc=open_file(url)
      xml=open_file(Constant::BACK_PUBLIC_PATH + @exam_user.paper.paper_url)
      ExamRater.set_answer(score_reason,@exam_user,xml,doc,url)
      @exam_relation.toggle!(:is_marked)
      notice="提交成功"
    rescue
      notice="提交失败"
    end
    respond_to do |format|
      format.json {
        data={:examination_id => @exam_user.examination_id, :rater_id => @exam_relation.exam_rater_id, :notice => notice}
        render :json=>data
      }
    end
  end

  def log_out #退出
    cookies.delete(:rater_id)
    cookies.delete(:examination_id)
    cookies.delete(:rater_name)
    render :inline=>"<script>window.close();</script>"
  end

end
