class CreateEpisodes < ActiveRecord::Migration[7.0]
  def change
    create_table :episodes do |t|
      t.references :book, null: false, foreign_key: true
      t.string :name
      t.integer :qty
      t.string :intro
      t.text :content
      t.integer :compensation_fee
      t.string :thumb

      t.timestamps
    end
  end
end
