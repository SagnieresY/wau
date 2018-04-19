class CreateInvestmentTags < ActiveRecord::Migration[5.1]
  def change
    create_table :investment_tags do |t|
      t.string :name
      t.references :investment, foreign_key: true

      t.timestamps
    end
  end
end
