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
  def self.create!(geo_attributes) #improved project create!
    geo = Geo.where(name:geo_attributes[:name]) #gets project by name

    if geo.blank? #check if a project whith the name exists
      return super(geo_attributes) #if not it creates it
    end

    return geo[0] #if yes it returns it
  end

  def self.create(attributes)
    self.create!(attributes)
  end

end
