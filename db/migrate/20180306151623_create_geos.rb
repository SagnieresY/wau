class CreateGeos < ActiveRecord::Migration[5.1]
  def change
    create_table :geos do |t|
      t.string :name
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
