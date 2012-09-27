class AddCodeToAgreement < ActiveRecord::Migration
  def change
    add_column :agreements, :code, :string
  end
end
