# encoding: utf-8
class SimulationsController < ApplicationController
  layout "application", :except => ['show', 'show_result']
  before_filter :sign?, :except => "index"


  def do_exam
    @exam_user = ExamUser.find_by_examination_id_and_p_types_and_user_id(params[:id].to_i,
      ExamUser::P_TYPES[:MOKAO], cookies[:user_id].to_i)
    @exam_user = ExamUser.create(:user_id => cookies[:user_id].to_i,:examination_id => params[:id].to_i,
      :password => User::DEFAULT_PASSWORD, :p_types => ExamUser::P_TYPES[:MOKAO],
      :is_user_affiremed => ExamUser::IS_USER_AFFIREMED[:YES]) if @exam_user.nil?
    redirect_to "/simulations/#{@exam_user.id}"
  end

  def show
    @exam_user = ExamUser.find_by_id(params[:id].to_i)
    if @exam_user
      @examination = Examination.find_by_id(@exam_user.examination_id)
      @exam_user.set_paper(@examination) if @exam_user.paper_id.nil?
      @title = "#{@examination.title}模拟考试"
      if @exam_user.paper_id
        @paper_url = "#{Constant::BACK_SERVER_PATH}#{@exam_user.paper.paper_js_url}"
        @exam_user.update_info_for_join_exam(@examination.category_id) if @exam_user.started_at.nil? or @exam_user.started_at == ""
        render :layout => "simulations"
      else
        flash[:warn] = "试卷加载错误，请您重新尝试。"
        redirect_to "/simulations?category=#{@examination.category_id}"
      end
    else
      flash[:warn] = "试卷加载错误，请您重新尝试。"
      redirect_to "/simulations?category=#{@examination.category_id}"
    end
    p @paper_url
  end

  def show_result
    @exam_user = ExamUser.find_by_id(params[:id].to_i)
    if @exam_user
      @examination = Examination.find_by_id(@exam_user.examination_id)
      @title = "#{@examination.title}模拟考试"
      if @exam_user.paper_id
        @paper_url = "#{Constant::BACK_SERVER_PATH}#{@exam_user.paper.paper_js_url}"
        @answer_url = @paper_url.gsub("paperjs", "answerjs")
        @collection_info = CollectionInfo.find_by_paper_id_and_user_id(@exam_user.paper_id,
          @exam_user.user_id)
        render :layout => "result"
      else
        flash[:warn] = "试卷加载错误，请您重新尝试。"
        redirect_to "/simulations?category=#{@examination.category_id}"
      end
    else
      flash[:warn] = "试卷加载错误，请您重新尝试。"
      redirect_to "/simulations?category=#{@examination.category_id}"
    end
  end

  def get_exam_time
    text = return_exam_time(params[:id].to_i, cookies[:user_id].to_i)
    render :text => text
  end

  def return_exam_time(examnation_id, user_id)
    text = ""
    @examination = Examination.find(examnation_id)
    @exam_user = ExamUser.find_by_examination_id_and_p_types_and_user_id(@examination.id,
      ExamUser::P_TYPES[:MOKAO], user_id)
    if @exam_user
      end_time = (@exam_user.ended_at - Time.now) unless @exam_user.ended_at.nil? or @exam_user.ended_at == ""
    end
    if end_time.nil? or end_time == ""
      text = "不限时"
    elsif end_time > 0
      text = end_time
    else
      text = 0.1
    end
    return text
  end

  def five_min_save
    unless params[:arr].nil? or params[:arr] == ""
      @exam_user = ExamUser.find_by_examination_id_and_p_types_and_user_id(params[:id].to_i,
        ExamUser::P_TYPES[:MOKAO], cookies[:user_id].to_i)
      questions = params[:arr].split(",")
      question_hash = {}
      0.step(questions.length-1, 3) do |i|
        question_hash[questions[i]] = [questions[i+1], questions[i+2]]
      end if questions.any?
      str=@exam_user.update_answer_url(@exam_user.open_xml, question_hash)
      @exam_user.generate_answer_sheet_url(str, "result")
    end
    render :text => ""
  end

  def save_result
    @exam_user = ExamUser.find_by_examination_id_and_p_types_and_user_id(params[:id].to_i,
      ExamUser::P_TYPES[:MOKAO], cookies[:user_id].to_i)
    if @exam_user and (@exam_user.is_submited.nil? or @exam_user.is_submited == false)
      question_hash = {}
      question_ids = params[:all_quesiton_ids].split(",") if params[:all_quesiton_ids]
      question_ids.each do |question_id|
        question_hash[question_id] = [params["answer_" + question_id], "1"]
      end if question_ids
      @exam_user.generate_answer_sheet_url(
        @exam_user.update_answer_url(@exam_user.open_xml, question_hash, params[:block_ids]), "result")
      @exam_user.submited!
      #      ActionLog.exam_log(params[:category_id], cookies[:user_id])
      render :layout => "simulations"
    else
      render "error_page", :layout => "simulations"
    end
  end

  def cancel_exam
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
    @exam_user.destroy if @exam_user
    render :update do |page|
      page.replace_html "remote_div" , :text => ""
    end
  end

  def goto_exam
    redirect_to "/simulations?category=#{params[:category]}"
  end

  def reset_exam
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
    @exam_user.destroy if @exam_user
    do_exam
  end

  def end_exam
    @exam_user = ExamUser.find_by_examination_id_and_user_id(params[:id].to_i, cookies[:user_id].to_i)
    if @exam_user and (@exam_user.is_submited.nil? or @exam_user.is_submited == false)
      @exam_user.submited!
      ActionLog.exam_log(params[:category_id], cookies[:user_id])
      flash[:notice] = "您的试卷已经成功提交。"
    else
      flash[:warn] = "您已经交卷。"
    end
    redirect_to "/simulations?category=#{params[:category]}"
  end
    
end
