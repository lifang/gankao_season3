class Sun < ActiveRecord::Base
  belongs_to :user

   TYPES = {:REGISTER => 1, :FIRSTLOGIN => 2, :CHECKIN => 3,:SHARE => 4}
end
