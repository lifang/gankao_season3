#encoding: utf-8
class QuestionsController < ApplicationController
  layout 'main'
  def index
    redirect_to :action => 'ask'
  end
  
  def answered
    #获取已经回答的问题
    @answered_questions=UserQuestion.where("is_answer=true").find(:all)
    .paginate(:page=>params[:page],:per_page=>2)
  end

  def unanswered
    #获取问题--没有正确答案的题目
    sql="SELECT * FROM exam_app.user_questions where id not in
        (select user_question_id from exam_app.question_answers where is_right=true group by user_question_id )
         order by created_at desc"
    @unanswered_questions=UserQuestion.paginate_by_sql(sql,
      :page => params[:page],:per_page=>2)
    
  end

  def ask
    @user=User.find(22)
    #获取我提问的问题
    @myasks=@user.user_questions.paginate(:page=>params[:page],:per_page=>2)
  end

  def answers
    @user=User.find(22)
    #获取我回答的
    @myanswers=@user.question_answers.paginate(:page=>params[:page],:per_page=>2)
  end

  def show_result
    @keyword=params[:keywords]
    sql="SELECT * FROM exam_app.user_questions where title like concat_ws('#{@keyword}','%','%')
      or description like concat_ws('#{@keyword}','%','%') order by created_at desc"
    @query_questions=UserQuestion.paginate_by_sql(sql,
      :page => params[:page],:per_page=>2)
  end

  def save_answer
    #获取参数
    @answer=params[:question_answer][:answer]
    @user_question_id=params[:question_answer][:user_question_id]
    #获取当前用户
    @user=User.find(24)
    #创建
    QuestionAnswer.create(:user_id=>@user.id,:answer=>@answer,:user_question_id=>@user_question_id)
    #更新题目的is_answer字段
    @question=UserQuestion.find(@user_question_id)
    if(@question.is_answer==false)
      @question.is_answer=true
    end
    @question.save #更新保存
    
    redirect_to '/questions/answered'
  end

  def ask_question
    @uq=UserQuestion.new(params[:user_question])
    @uq.user_id=22
    @uq.category_id=2
    @uq.save
    redirect_to '/questions/ask'
  end
end
