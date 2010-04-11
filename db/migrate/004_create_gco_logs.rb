class CreateGcoLogs < ActiveRecord::Migration
  def self.up
    create_table :gco_logs, :id => true, :force => true  do |t|
      t.timestamp  :created_on, :null => false
      t.integer    :project_id, :null => false
      t.string     :author, :null => false
      t.string     :title, :null => false
      t.string     :msg_log, :null => false
    end

  end
  
  def self.down
    drop_table :gco_logs
  end
end
