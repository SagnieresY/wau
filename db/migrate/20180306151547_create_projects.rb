class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :ngo
      t.string :focus_area
      t.string :main_contact

      t.timestamps
    end
  end
end
