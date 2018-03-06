class AddFoundationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :foundation, foreign_key: true
  end
end
