class QuestionsController < ApplicationController
  layout 'main'
  def index
    redirect_to :action => 'ask'
  end
  
  def answered
    category=params[:category]
    category=2
    #获取已经回答的问题
    @answered_questions=UserQuestion.where("is_answer=true and category_id=#{category}").find(:all)
    .paginate(:page=>params[:page],:per_page=>2)
  end

  def unanswered
    category=params[:category]
    category=2

    @user=User.find(22)
    @result=[]

     #获取问题--没有正确答案的题目并且当前用户没有答过的
    UserQuestion.find_all_by_category_id(category).each do |question|
      current_user_answered=false #当前是否答过
      n=0;#是否已经有正确答案
      question.question_answers.each do|answer|
        if answer.user_id==@user.id  #答案里有用户id 表示当前用户已经答过了
          current_user_answered=true
        end
        if answer.is_right==true #有正确答案
          n=n+1;
        end
      end
      if n==0 && current_user_answered==false
        @result<<question  #将符合条件的题目添加到数组中
      end
    end
    
    @unanswered_questions=@result.paginate(:page=>params[:page],:per_page=>2)
    
   
#    sql="SELECT * FROM exam_app.user_questions where category_id=#{category} and id not in
#        (select user_question_id from exam_app.question_answers where is_right=true group by user_question_id )
#         order by created_at desc"
#    @unanswered_questions=UserQuestion.paginate_by_sql(sql,
#     :page => params[:page],:per_page=>2)
  end

  def ask
    #获取当前用户和类别
    @user=User.find(22)
    category=params[:category]
    category=2
    
    #获取我提问的问题
    @myasks=@user.user_questions.where("category_id=#{category}").find(:all)
    .paginate(:page=>params[:page],:per_page=>2)
  end

  def answers

    #获取当前用户
    @user=User.find(22)
    category=params[:category]
    category=2
    @result=[]
    
    #获取我回答的
    @user.question_answers.each do |answer|
      # 获取当前类别的回答
      if answer.user_question.category_id==category
        @result<<answer
      end
    end
    @myanswers=@result.paginate(:page=>params[:page],:per_page=>2)
  end

  def show_result
    category=params[:category]
    category=2
    
    @keyword=params[:keywords]
    sql="SELECT * FROM exam_app.user_questions where category_id=#{category} and title like concat_ws('#{@keyword}','%','%')
      or description like concat_ws('#{@keyword}','%','%') order by created_at desc"
    @query_questions=UserQuestion.paginate_by_sql(sql,
      :page => params[:page],:per_page=>2)
  end

  def save_answer
    #获取参数
    @answer=params[:question_answer][:answer]
    @user_question_id=params[:question_answer][:user_question_id]
    #获取当前用户
    @user=User.find(22)
    #创建
    QuestionAnswer.create(:user_id=>@user.id,:answer=>@answer,:user_question_id=>@user_question_id)
    #更新题目的is_answer字段
    @question=UserQuestion.find(@user_question_id)
    #如果提问问题的用户是当前用户就不改变is_answer的值
    if @user.id!=@question.user_id
      if(@question.is_answer==false)
        @question.is_answer=true
      end
      @question.save #更新保存
    end
    redirect_to '/questions/answered'
  end

  def ask_question
    category=params[:category]
    category=2
    
    @uq=UserQuestion.new(params[:user_question])
    @uq.user_id=22 #获取当前用户
    @uq.category_id=category #获取类别id
    @uq.save
    redirect_to '/questions/ask'
  end
end
