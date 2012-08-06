class LoginsController < ApplicationController

  def index
    p User.all
  end
end
