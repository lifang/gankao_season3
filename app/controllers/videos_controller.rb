#encoding: utf-8
class VideosController < ApplicationController
  layout 'main'
  respond_to :html, :xml, :json

  def index
    category=params[:category].nil? ? 2 : params[:category]
    @schedules=Schedule.find_by_sql("select id,name from schedules where category_id=#{category}")
  end


  def show
    render  :layout=>false
  end


  def request_url
    video_url=Video.find(params[:video_id].to_i).video_url
    respond_to do |format|
      format.json {
        render :json=>{:video_url=>video_url}
      }
    end
  end

  

  def request_video
    sche=params[:schedule_id].to_i
    @schedule=Schedule.find(sche)
    respond_with do |format|
      format.js
    end
  end
end
