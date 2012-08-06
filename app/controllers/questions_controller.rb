class QuestionsController < ApplicationController
  layout 'main'
  def index
     redirect_to :action => 'ask'
  end
  
  def answered

  end

  def unanswered

  end

  def ask

  end
end
