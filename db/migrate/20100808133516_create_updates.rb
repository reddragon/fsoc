class CreateUpdates < ActiveRecord::Migration
  def self.up
    create_table :updates do |t|
      t.string :user_group
      t.integer :user_id
      t.text :message
      t.string :link_string
      t.string :link
      t.timestamps
    end
  end

  def self.down
    drop_table :updates
  end
end
