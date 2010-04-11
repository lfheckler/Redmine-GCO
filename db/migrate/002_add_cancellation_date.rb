 class AddCancellationDate < ActiveRecord::Migration
    def self.up
      add_column :baselines, :cancellation_date, :datetime
    end

    def self.down
      remove_column :baselines, :cancellation_date
    end
  end
