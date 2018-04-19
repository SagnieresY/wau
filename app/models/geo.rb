class Geo < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name,
    against: [:name],
    using: {
      tsearch: { prefix: true }
    }

  has_and_belongs_to_many :projects
  validates :name, presence: true, uniqueness: true
  attribute :name
end
