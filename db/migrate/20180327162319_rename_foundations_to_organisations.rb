class RenameFoundationsToOrganisations < ActiveRecord::Migration[5.1]
  def change
    rename_table :foundations, :organisations
  end
end
