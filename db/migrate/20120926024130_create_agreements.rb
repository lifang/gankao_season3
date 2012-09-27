class CreateAgreements < ActiveRecord::Migration
  def change
    create_table :agreements do |t|
      t.integer :category_id
      t.integer :user_id
      t.string :name
      t.string :id_card
      t.string :alipay
      t.string :agreement_url
      t.timestamps
    end
    add_index :agreements,:category_id
    add_index :agreements,:user_id
  end
end
