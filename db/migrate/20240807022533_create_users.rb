class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.integer :role
      t.date :dob
      t.string :phone
      t.integer :lost_time
      t.boolean :blacklisted
      t.boolean :activated

      t.timestamps
    end
  end
end
