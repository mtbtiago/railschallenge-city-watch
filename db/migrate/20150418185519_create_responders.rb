class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.integer :emergency_code
      t.string :type
      t.string :name
      t.integer :capacity
      t.boolean :on_duty

      t.timestamps null: false
    end
    add_index :responders, :name, unique: true
  end
end
