class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :address_book_id, :null => false
      t.string :uid, :unique => true, :null => false
      t.timestamps
    end
  end
end
