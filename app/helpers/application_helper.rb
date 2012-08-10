module ApplicationHelper

  def proof_code(chars, len)
    code_array = []
    1.upto(len) {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end
end
