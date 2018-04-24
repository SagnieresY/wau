class CreateJoinTableInvestmentsInvestmentTags < ActiveRecord::Migration[5.1]
  def change
    create_join_table :investments, :investment_tags do |t|
      # t.index [:investment_id, :investment_tag_id]
      # t.index [:investment_tag_id, :investment_id]

      t.timestamps
    end
  end
end
