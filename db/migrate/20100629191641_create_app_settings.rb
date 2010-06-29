class CreateAppSettings < ActiveRecord::Migration
  def self.up
    create_table :app_settings do |t|
      t.datetime :pct_from
      t.datetime :pct_to
      t.datetime :pst_from
      t.datetime :pst_to
      t.datetime :pat_from
      t.datetime :pat_to
      t.datetime :csd_on
      t.datetime :met_from
      t.datetime :met_to
      t.datetime :ced_on
      t.datetime :fet_from
      t.datetime :fet_to
      t.timestamps
    end
  end

  def self.down
    drop_table :app_settings
  end
end
