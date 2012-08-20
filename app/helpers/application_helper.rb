module ApplicationHelper
  include LearnHelper
  
  def user_info
    cookies[:user_id]=1
    user_id=cookies[:user_id]
    category=params[:category].nil?? "2":params[:category]
    user_sun=Sun.find_by_sql("select users.name,users.school,users.email,suns.num from users,suns where
      users.id=suns.user_id and users.id=#{user_id} and suns.category_id=#{category}")[0]
  end
end
