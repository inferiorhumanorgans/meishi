class CreateAddressBooks < ActiveRecord::Migration
  def change
    create_table :address_books do |t|
      t.string :name, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
  end
end
