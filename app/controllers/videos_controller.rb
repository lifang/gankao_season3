#encoding: utf-8
class VideosController < ApplicationController
  layout 'main'
  def index
    category=params[:category_id].nil? ? 2 : params[:category_id]
    schedules=Schedule.find_by_sql("select id,name from schedules where category_id=#{category}")
    @sched_vis={}
    schedules.each do |schedule|
      @sched_vis[schedule.id]=[schedule.videos,schedule.name]
    end unless schedules.blank?
  end


  def show
    render  :layout=>false
  end
 
end
