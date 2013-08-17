class AddPerUserQuota < ActiveRecord::Migration
  def up
    add_column :users, :quota_limit, :integer, default: 0
  end

  def down
    remove_column :users, :quota_limit
  end
end
