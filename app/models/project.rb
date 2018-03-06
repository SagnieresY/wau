class Project < ApplicationRecord
  has_many :projects_geos
  has_many :geos, through: :projects_geos
  has_many :investments
  has_many :milestones, through: :investments
  validates :name, presence: true
  validates :description, presence: true
  validates :ngo, presence: true
  validates :focus_area, presence: true
  validates :main_contact, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
    message: "Please enter an valid email" }
end
