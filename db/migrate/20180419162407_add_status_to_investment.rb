class AddStatusToInvestment < ActiveRecord::Migration[5.1]
  def change
    add_column :investments, :status, :string, default: "ongoing"
  end
end
