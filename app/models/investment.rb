class Investment < ApplicationRecord
  belongs_to :foundation
  belongs_to :project
  has_many :milestones
  validates :project, presence: true
  validates :foundation, presence: true
end
