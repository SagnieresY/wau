class CreateInvestments < ActiveRecord::Migration[5.1]
  def change
    create_table :investments do |t|
      t.references :foundation, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
