class AddDefaultFoundationToUser < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :foundation_id, :integer, :default => ""
  end
end
