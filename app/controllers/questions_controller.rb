class QuestionsController < ApplicationController
  layout 'main'
  def index
    redirect_to :action => 'ask'
  end
  
  def answered
    #获取已经回答的问题
    @answered_questions=UserQuestion.where("is_answer=true").find(:all)
    .paginate(:page=>params[:page],:per_page=>1)
  end

  def unanswered
    #获取未回答的问题
    @unanswered_questions=UserQuestion.where("is_answer=false").find(:all)
    .paginate(:page => params[:page],:per_page=>1)
  end

  def ask
    @user=User.find(22)
    #获取我提问的问题
    @myask=@user.user_questions
  end

  def answers

  end
end
