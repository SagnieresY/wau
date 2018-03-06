class CreateFoundations < ActiveRecord::Migration[5.1]
  def change
    create_table :foundations do |t|
      t.string :name
      t.string :logo

      t.timestamps
    end
  end
end
