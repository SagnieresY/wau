class Investment < ApplicationRecord
  belongs_to :foundation
  belongs_to :project
end
