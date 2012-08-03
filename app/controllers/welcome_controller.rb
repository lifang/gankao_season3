class WelcomeController < ApplicationController
  
  def index

    render "index", :alert => "Watch it, mister!"
  end

end
