class RemoveGeoIdFromProject < ActiveRecord::Migration[5.1]
  def change
    remove_column :geos, :project_id
  end
end
