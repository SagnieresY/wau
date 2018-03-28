class RemoveNgoAndFocusAreaFromProjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :ngo
    remove_column :projects, :focus_area
  end
end
