class ApplicationController < ActionController::Base
  protect_from_forgery
  include Constant
  include ApplicationHelper


  def send_message
    @return_message = ""
    @web = ""
    if params[:web] == "sina"
      @web = "sina"
      ret = sina_send_message(cookies[:access_token], params[:message])
      @return_message = "微博发送失败，请重新尝试" if ret["error_code"]
    elsif params[:web] == "renren"
      @web = "renren"
      @type = params[:type]
      @secret_key = @type == "8" ? @@renren8_secret_key : (@type=="6" ? @@renren6_secret_key : @@renren_secret_key)
      ret = renren_send_message(cookies[:access_token], params[:message], @secret_key , @type)
      @return_message = "分享失败，请重新尝试" if ret[:error_code]
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
end
