class CreateMilestones < ActiveRecord::Migration[5.1]
  def change
    create_table :milestones do |t|
      t.text :task
      t.date :deadline
      t.boolean :unlocked, default: false
      t.integer :amount
      t.references :investment, foreign_key: true

      t.timestamps
    end
  end
end
