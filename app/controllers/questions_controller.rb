#encoding: utf-8
class QuestionsController < ApplicationController
  layout 'main'
  before_filter :sign?, :only => ["save_answer", "ask_question"]


  #获取已经回答的问题
  def answered
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
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
    @current_page = params[:current_page].nil? ? "answered" : params[:current_page]
    @question_answers = QuestionAnswer.paginate_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at asc", @user_question.id], :page => params[:page], :per_page => 5)
  end

  def unanswered
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
    @unanswered_questions = UserQuestion.paginate_by_sql(["select uq.*, u.name user_name, u.cover_url
          from user_questions uq left join users u on u.id = uq.user_id
          where uq.is_answer = #{UserQuestion::IS_ANSWERED[:NO]} and uq.category_id = ? order by created_at desc",
        category], :page => params[:page], :per_page => 3)
    @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @unanswered_questions[0].id]) if @unanswered_questions.any?
  end

  #ajax获取问题的答案
  def get_answers
    @current_page = params[:current_page]
    @user_question = UserQuestion.find(params[:id].to_i)   
    @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @user_question.id])
  end

  #获取我提问的问题
  def ask
    #获取当前用户和类别
    user_id = cookies[:user_id].to_i
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
    if user_id
      @myasks=UserQuestion.paginate_by_sql(["select uq.*, u.name user_name, u.cover_url
          from user_questions uq left join users u on u.id = uq.user_id
          where uq.category_id = ? and  uq.user_id=? order by created_at desc",
          category, user_id], :page => params[:page], :per_page => 3)
      @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @myasks[0].id]) if @myasks.any?
    end
  end

  def answers
    #获取当前用户
    user_id = cookies[:user_id].to_i
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
    if user_id
      #获取我回答问题的
      @myanswers=UserQuestion.paginate_by_sql(["select user_questions.*,users.name user_name,users.cover_url from
      user_questions,users where category_id=? and users.id=user_questions.user_id  and
      user_questions.id in (SELECT user_question_id from question_answers where user_id=?
      group by user_question_id)" ,category ,user_id],
        :page=>params[:page],:per_page=>3)

      @question_answers = QuestionAnswer.find_by_sql(["select qa.*, u.name user_name, u.cover_url
        from question_answers qa left join users u on u.id = qa.user_id where user_question_id = ?
        order by is_right desc, created_at desc limit 3", @myanswers[0].id]) if @myanswers.any?
    end
  end

  def show_result
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i    
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
    #获取当前用户
    user_id=cookies[:user_id]
    #获取参数
    @answer = params[:question_answer][:answer].strip
    @user_question_id = params[:question_answer][:user_question_id]
    QuestionAnswer.create(:user_id => user_id,:answer => @answer,:user_question_id => @user_question_id)
    redirect_to request.referer
  end

  def ask_question
    category = (params[:category].nil? or params[:category].empty?) ? 2 : params[:category].to_i
    user_id=cookies[:user_id]
    @uq=UserQuestion.new(params[:user_question])
    @uq.user_id=user_id #获取当前用户
    @uq.category_id=category #获取类别id
    @uq.save
    redirect_to '/questions/ask?category='+category.to_s
  end
end
