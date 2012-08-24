class AddLoginTimesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_times, :integer, :default => 0
  end
end
