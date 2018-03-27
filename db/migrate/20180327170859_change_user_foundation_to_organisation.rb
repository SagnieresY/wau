class ChangeUserFoundationToOrganisation < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :foundation_id, :organisation_id
  end
end
