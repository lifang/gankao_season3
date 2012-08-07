#encoding: utf-8
class VideosController < ApplicationController
  layout 'main'
  def index
    schedules=Schedule.find_by_sql("select id,name from schedules where category_id=#{2}")
    @sched_vis={}
    schedules.each do |schedule|
     @sched_vis[schedule.id]=[schedule.videos,schedule.name]
    end unless schedules.blank?
  end

 
end
