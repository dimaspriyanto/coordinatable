module Coordinatable
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :acts_as_coordinatable

    base_object = base.new
    if !base_object.respond_to?(:latitude) or !base_object.respond_to?(:longitude)
      raise "#{base} needs 'latitude' and 'longitude' attributes"
    end
  end

  module InstanceMethods
    def coordinates
      [self.latitude, self.longitude]
    end

    def string_coordinates
      coordinates.join(", ")
    end

    def coordinates_validation
      if self.latitude.blank?
        self.errors.add :latitude, "can't be blank"
      elsif self.latitude > 90 or self.latitude < -90
        self.errors.add :latitude, 'is invalid'
      end

      if self.longitude.blank?
        self.errors.add :longitude, "can't be blank"
      elsif self.longitude > 90 or self.longitude < -90
        self.errors.add :longitude, 'is invalid'
      end
    end
  end

  module ClassMethods
    def acts_as_coordinatable
      send :include, InstanceMethods
      validate :coordinates_validation

      send :include, Geocoder::Model::Mongoid
      reverse_geocoded_by :coordinates
      after_validation :reverse_geocode
    end
  end

end
