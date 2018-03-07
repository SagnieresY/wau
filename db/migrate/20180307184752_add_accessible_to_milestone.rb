class AddAccessibleToMilestone < ActiveRecord::Migration[5.1]
  def change
    add_column :milestones, :accessible, :boolean, default: true
  end
end
