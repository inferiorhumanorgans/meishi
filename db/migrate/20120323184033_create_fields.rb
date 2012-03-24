class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.integer :contact_id, :null => false
      t.string :name, :null => false
      t.string :value, :null => false
      t.timestamps
    end
  end
end
