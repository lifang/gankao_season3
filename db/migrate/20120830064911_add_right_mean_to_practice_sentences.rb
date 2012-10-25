class AddRightMeanToPracticeSentences < ActiveRecord::Migration
  def change
    add_column :practice_sentences, :right_mean, :string
  end
end
