class AddCharityNumberToOrganisation < ActiveRecord::Migration[5.1]
  def change
    add_column :organisations, :charity_number, :integer
  end
end
