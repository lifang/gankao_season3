#encoding: utf-8
class QuestionsController < ApplicationController
  layout 'main'
  def index
    params[:category]='2' if params[:category].nil?
    redirect_to '/questions/ask?category='+params[:category]
  end
  
  def answered
    params[:category]='2' if params[:category].nil?
    category = params[:category].empty? ? 2 : params[:category].to_i
   
    #获取已经回答的问题
    @answered_questions = UserQuestion.paginate_by_sql(["select uq.*, u.name user_name, u.cover_url
          from user_questions uq left join users u on u.id = uq.user_id
          where uq.is_answer = #{UserQuestion::IS_ANSWERED[:YES]} and uq.category_id = ? order by created_at desc",
        category], :page => params[:page], :per_page => 3)
    @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @answered_questions[0].id]) if @answered_questions.any?
  end

  def answered_more
    @user_question = UserQuestion.find(params[:id].to_i)
    @question_answers = QuestionAnswer.paginate_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at asc", @user_question.id], :page => params[:page], :per_page => 5)
  end

  def unanswered
    params[:category]="2" if params[:category].nil?
    category = params[:category].empty? ? 2 : params[:category].to_i
    @unanswered_questions = UserQuestion.paginate_by_sql(["SELECT user_questions.*,users.name user_name,users.cover_url FROM
    user_questions,users where category_id=? and users.id=user_questions.user_id and user_questions.id not in
    (select user_question_id from question_answers where is_right=true group by user_question_id )
      order by created_at desc", category], :page => params[:page], :per_page => 3)
    @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @unanswered_questions[0].id]) if @unanswered_questions.any?
  end

  #ajax获取问题的答案
  def get_answers
    @user_question = UserQuestion.find(params[:id].to_i)
    @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @user_question.id])
  end

  def ask
    #获取当前用户和类别
    cookies[:user_id]=24
    user_id=cookies[:user_id]
    params[:category]="2" if params[:category].nil?
    category = params[:category].empty? ? 2 : params[:category].to_i
    #获取我提问的问题

    @myasks=UserQuestion.paginate_by_sql(["select uq.*, u.name user_name, u.cover_url
          from user_questions uq left join users u on u.id = uq.user_id
          where uq.user_id=? and uq.category_id = ? order by created_at desc",
        user_id,category], :page => params[:page], :per_page => 3)

    @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @myasks[0].id]) if @myasks.any?
    
  end

  def answers
    #获取当前用户
    cookies[:user_id]=24
    user_id=cookies[:user_id]
    params[:category]="2" if params[:category].nil?
    category = params[:category].empty? ? 2 : params[:category].to_i
    
    #获取我回答问题的
    @myanswers=UserQuestion.paginate_by_sql(["select user_questions.*,users.name user_name,users.cover_url from
user_questions,users where user_questions.id in (SELECT user_question_id from question_answers where user_id=?
group by user_question_id) and category_id=? and users.id=user_questions.user_id",user_id,category],
      :page=>params[:page],:per_page=>3)

    @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @myanswers[0].id]) if @myanswers.any?
  end

  def show_result
    params[:category]="2" if params[:category].nil?
    category = params[:category].empty? ? 2 : params[:category].to_i
    
    @keyword=params[:keywords]
   
    @query_questions=UserQuestion.paginate_by_sql(["select uq.*, u.name user_name, u.cover_url
          from user_questions uq left join users u on u.id = uq.user_id
          where uq.category_id = ? and (title like concat_ws('#{@keyword}','%','%')
      or description like concat_ws('#{@keyword}','%','%')) order by created_at desc",
        category], :page => params[:page], :per_page => 3)

    @question_answers=QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @query_questions[0].id]) if @query_questions.any?
  end

  def save_answer
    #获取参数
    @answer=params[:question_answer][:answer]
    @user_question_id=params[:question_answer][:user_question_id]
    #获取当前用户
    cookies[:user_id]=24
    user_id=cookies[:user_id]
    #创建
    QuestionAnswer.create(:user_id=>user_id,:answer=>@answer,:user_question_id=>@user_question_id)
    #更新题目的is_answer字段
    @question=UserQuestion.find(@user_question_id)
    #如果提问问题的用户是当前用户就不改变is_answer的值
    if user_id!=@question.user_id
      if(@question.is_answer==false)
        @question.is_answer=true
      end
      @question.save #更新保存
    end
    params[:category]="2" if params[:category].nil?
    category = params[:category].empty?? 2 : params[:category].to_i
    redirect_to '/questions/answered?category='+category.to_s
  end

  def ask_question
    params[:category]="2" if params[:category].nil?
    category = params[:category].empty?? 2 : params[:category].to_i
    cookies[:user_id]=24
    user_id=cookies[:user_id]
    @uq=UserQuestion.new(params[:user_question])
    @uq.user_id=user_id #获取当前用户
    @uq.category_id=category #获取类别id
    @uq.save
    redirect_to '/questions/ask?category='+category.to_s
  end
end
