module SkillsHelper

  def handle_paginate(page, total_page)
    html = "<div class='pageTurn'>"
    if page and page.to_i > 1
      html += "<a href='#{request.url.split("&page")[0]}&page=#{page.to_i - 1}'>&lt; Prev</a>"
    else
      html += "<span class='disabled'> &lt; Prev</span>"
    end
    current_page = (page and page.to_i > 1) ? page.to_i : 1
    if total_page > 12
      if current_page <= 6
        (1..current_page).each do |i|
          if current_page == i
            html += "<em class='current'>#{i}</em>"
          else
            html += "<a href='#{request.url.split("&page")[0]}&page=#{i}'>#{i}</a>"
          end
        end
      else
        (1..2).each do |i|
          html += "<a href='#{request.url.split("&page")[0]}&page=#{i}'>#{i}</a>"
        end
        end_page = (total_page - current_page) < 6 ? current_page -2 : current_page
        html += "..." if (end_page -3) > 3
        ((end_page-3)..current_page).each do |i|
          if current_page == i
            html += "<em class='current'>#{i}</em>"
          else
            html += "<a href='#{request.url.split("&page")[0]}&page=#{i}'>#{i}</a>"
          end
        end
      end
      if current_page + 5 >= total_page
        ((current_page+1)..total_page).each do |i|
          html += "<a href='#{request.url.split("&page")[0]}&page=#{i}'>#{i}</a>"
        end
      else
        start_page = current_page+3 <= 6 ? current_page + 2 : current_page
        ((current_page+1)..start_page+3).each do |i|
          html += "<a href='#{request.url.split("&page")[0]}&page=#{i}'>#{i}</a>"
        end
        html += "..." if start_page+4 < (total_page-1)
        ((total_page-1)..total_page).each do |i|
          html += "<a href='#{request.url.split("&page")[0]}&page=#{i}'>#{i}</a>"
        end
      end
    else
      (1..total_page).each do |i|
        if current_page == i
          html += "<em class='current'>#{i}</em>"
        else
          html += "<a href='#{request.url.split("&page")[0]}&page=#{i}'>#{i}</a>"
        end
      end
    end
    if  page.to_i < total_page and total_page!=1
      html += "<a href='#{request.url.split("&page")[0]}&page=#{current_page + 1}'>Next&gt;</a>"
    else
      html += "<span class='disabled'> Next&gt;</span>"
    end
    return (html+"</div>").html_safe
  end
end
