class AddFocusAreaToProjects < ActiveRecord::Migration[5.1]
  def change
    add_reference :projects, :focus_area, foreign_key: true
  end
end
