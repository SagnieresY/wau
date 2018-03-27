class ChangeInvestmentFoundationToOrganisation < ActiveRecord::Migration[5.1]
  def change
    rename_column :investments, :foundation_id, :organisation_id
  end
end
