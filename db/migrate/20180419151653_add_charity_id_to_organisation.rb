class AddCharityIdToOrganisation < ActiveRecord::Migration[5.1]
  def change
    add_column :organisations, :charity_id, :integer
  end
end
