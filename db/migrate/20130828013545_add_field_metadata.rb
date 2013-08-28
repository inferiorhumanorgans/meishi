class AddFieldMetadata < ActiveRecord::Migration
  def up
    add_column :fields, :group, :string
    add_column :fields, :parameters, :string
  end

  def down
    remove_column :fields, :group
    remove_column :fields, :parameters
  end
end
