class CreateBaselineItems < ActiveRecord::Migration
  def self.up
    create_table :baseline_items, :id => false, :force => true  do |t|
      t.integer  :baseline_id, :null => false
      t.references :issue
    end

   add_index(:baseline_items, [:baseline_id,:issue_id], :unique => true)
  
  end
  
  def self.down
    drop_table :baseline_items
  end
end
