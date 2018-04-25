class InvestmentTag < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name,
    against: [ :name ],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }
  belongs_to :organisation
  has_and_belongs_to_many :investments
end
