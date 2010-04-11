class CreateBaselines < ActiveRecord::Migration
  def self.up
    create_table :baselines do |t|
      t.string :identifier, :null => false
      t.datetime :creation_date
      t.integer  :position
      t.integer  :project_id, :null => false
    end

   add_index(:baselines, [:identifier,:project_id], :unique => true)

  end

 
  def self.down
    drop_table :baselines
  end
end
