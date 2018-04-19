class CreateInvestmentsInvestmentTags < ActiveRecord::Migration[5.1]
  def change
    create_table :investments_investment_tags do |t|
      t.belongs_to :investment, index: true
      t.belongs_to :investment_tag, index: true
      t.timestamps
    end
  end
end
