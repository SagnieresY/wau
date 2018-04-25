

class InvestmentTag < ApplicationRecord
  belongs_to :organisation
  has_and_belongs_to_many :investments


end
