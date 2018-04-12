class UsersController < ApplicationController
  def users_csv
    authorize current_user
    send_data User.to_csv(current_user.organisation), filename: "Users-#{Date.today.to_s}.csv", type: 'text/csv'
  end

  def generate_users
    users_csv = params[:users_csv]
    users_attributes = []
    CSV.foreach(users_csv.path) do |user|
      users_attributes << user
    end

    redirect_to downloads_path
  end
end
