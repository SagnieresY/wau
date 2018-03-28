class CreateFocusAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :focus_areas do |t|
      t.string :name

      t.timestamps
    end
  end
end
