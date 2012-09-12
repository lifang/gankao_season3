# encoding: utf-8
class Tractate < ActiveRecord::Base

  READ_MAX_LEVEL = {:CET4 => 16, :CET6 => 21, :GRADUATE => 26}
  WRITE_MAX_LEVEL = {:CET4 => 16, :CET6 => 21, :GRADUATE => 26}

  def tractate_xml
    file=File.open "#{Constant::BACK_PUBLIC_PATH}#{self.tractate_url}"
    doc = Document.new(file)
    file.close
    return doc
  end
end
