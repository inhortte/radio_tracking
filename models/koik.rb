require 'dm-core'
require 'dm-migrations'

class Biotope
  include DataMapper::Resource

  property :id, Serial
  property :biotope, String, :length => 50

  has n, :radiotrackings
end

class DistanceFromWater
  include DataMapper::Resource

  property :id, Serial
  property :distance_from_water, String, :length => 50

  has n, :radiotrackings
end

class Observer
  include DataMapper::Resource

  property :id, Serial
  property :observer, String, :length => 50

  has n, :radiotrackings
end

class Precipitation
  include DataMapper::Resource

  property :id, Serial
  property :precipitation, String, :length => 50

  has n, :radiotrackings
end

class ReleasedAnimal
  include DataMapper::Resource

  property :id, Serial
  property :animal_id, Integer
  property :frequency, Integer
  property :nickname, String, :length => 20
  property :sex, String, :length => 10
  property :birthdate, DateTime
  property :release_date, DateTime
  property :microchip, String, :length => 30
  property :enclosure_type, String, :length => 30
  property :release_location_N, Float
  property :release_location_E, Float
  property :release_site, String, :length => 30
  property :remarks, Text

  has n, :radiotrackings
end

class Temperature
  include DataMapper::Resource

  property :id, Serial
  property :temperature, String, :length => 50

  has n, :radiotrackings
end

class WaterLevel
  include DataMapper::Resource

  property :id, Serial
  property :water_level, String, :length => 50

  has n, :radiotrackings
end

class WaterbodyType
  include DataMapper::Resource

  property :id, Serial
  property :waterbody_type, String, :length => 50

  has n, :radiotrackings
end

class Radiotracking
  include DataMapper::Resource

  property :id, Serial
  property :frequency, Integer
  property :nickname, String, :length => 30
  property :date, DateTime
  property :location_of_observer_E, Float
  property :location_of_observer_N, Float
  property :location_of_animal_E, Float
  property :location_of_animal_N, Float
  property :activity, Boolean, :default => false
  property :remarks, Text

  belongs_to :released_animal
  belongs_to :observer
  belongs_to :biotope
  belongs_to :distance_from_water
  belongs_to :waterbody_type
  belongs_to :water_level
  belongs_to :precipitation
  belongs_to :temperature
end
