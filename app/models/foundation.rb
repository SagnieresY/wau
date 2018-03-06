class Foundation < ApplicationRecord
  has_many :users
  has_many :investments
  has_many :projects, through: :investements
  has_many :milestones, through: :investments
end
