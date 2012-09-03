#encoding: utf-8

namespace :words do
  task(:level => :environment) do
#	file = File.open("#{Rails.root}/public/five.js")
#	json = JSON file.read
#	file.close
#    words = Word.where("info_tmp is null")
#	words.each do |word|
#    word.update_attribute("info_tmp",json["#{word.name}"])
#	  #word.update_attribute("info_tmp",json["#{word.name.downcase}"])
#    #word.update_attribute("info_tmp",json["#{word.name.gsub(/[0-9]*/, "")}"])
#	end
    level = 1
    Word.find(:all, :order => "info_tmp desc").each_with_index do |w, i|
      if (i+1)%100 == 0
        level += 1
      end
      w.update_attribute("level", level)
    end
  end
end


