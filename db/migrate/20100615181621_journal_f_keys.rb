class JournalFKeys < ActiveRecord::Migration
  def self.up
    add_column :journals, :user_id, :integer
  end

  def self.down
    remove_column :journals, :user_id
  end
end
