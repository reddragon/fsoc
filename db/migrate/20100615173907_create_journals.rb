class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.text :title
	  t.text :content
      t.references :task

      t.timestamps
    end
  end

  def self.down
    drop_table :journals
  end
end
