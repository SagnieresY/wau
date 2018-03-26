class DropMilestone < ActiveRecord::Migration[5.1]
  def change

    create_table :installments do |t|
      t.text :task
      t.date :deadline
      t.string :status, default: "locked"
      t.integer :amount, default: 0
      t.references :investment, foreign_key: true

      t.timestamps
    end
  end
end
