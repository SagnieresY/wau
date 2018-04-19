class Tag < ApplicationRecord
  belongs_to :investment
  has_one :organisation, through: :investment
end
