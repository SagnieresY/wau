class Foundation < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :investments, dependent: :destroy
  has_many :projects, through: :investements
  has_many :milestones, through: :investments
  validates :name, presence: true, uniqueness: true
end
