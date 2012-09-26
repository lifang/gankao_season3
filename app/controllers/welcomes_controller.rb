#encoding: utf-8
class WelcomesController < ApplicationController
 
  def index
    render :layout => false
  end

  def fast_icon
    render :text => 8
  end

end
