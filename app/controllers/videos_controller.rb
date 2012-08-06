class VideosController < ApplicationController
  layout 'main'
  def index
    schedules=Schedule.find_by_sql("select name,id from schedules where category_id=#{2}")
    @videos={}
    schedules.each do |schedule|

    end unless schedules.blank?

  end

 
end
