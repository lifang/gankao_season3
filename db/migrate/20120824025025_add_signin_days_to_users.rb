class AddSigninDaysToUsers < ActiveRecord::Migration
  def change
    add_column :users, :signin_days, :integer ,:default=>0
  end
end
