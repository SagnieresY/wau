class CreateGeosProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :geos_projects do |t|
      t.references :project, foreign_key: true
      t.references :geo, foreign_key: true

      t.timestamps
    end
  end
end
