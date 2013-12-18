require 'active_support/concern'
module Letsrate
  extend ActiveSupport::Concern

  def rate(stars, user, dimension=nil)
    dimension = nil if dimension.blank?

    if can_rate? user, dimension
      rates(dimension).create! do |r|
        r.stars = stars
        r.rater = user
      end
      update_rate_average(stars, dimension)
    else
      raise "User has already rated."
    end
  end

  def update_rate_average(stars, dimension=nil)
    if average(dimension).nil?
      RatingCache.create! do |avg|
        avg.cacheable_id = self.id
        avg.cacheable_type = self.class.name
        avg.avg = stars
        avg.qty = 1
        avg.dimension = dimension
      end
    else
      a = average(dimension)
      a.qty = rates(dimension).count
      a.avg = rates(dimension).average(:stars)
      a.save!(validate: false)
    end
  end

  def average(dimension=nil)
    dimension ?  self.send("#{dimension}_average") : rate_average_without_dimension
  end

  def can_rate?(user, dimension=nil)
    user.ratings_given.where(dimension: dimension, rateable_id: id, rateable_type: self.class.name).size.zero?
  end

  def rates(dimension=nil)
    dimension ? self.send("#{dimension}_rates") : rates_without_dimension
  end

  def raters(dimension=nil)
    dimension ? self.send("#{dimension}_raters") : raters_without_dimension
  end

  module ClassMethods

    def letsrate_rater
      has_many :ratings_given, :class_name => "Rate", :foreign_key => :rater_id
    end

    def letsrate_rateable(*dimensions)
      has_many :rates_without_dimension, -> { where dimension: nil}, :as => :rateable, :class_name => "Rate", :dependent => :destroy
      has_many :raters_without_dimension, :through => :rates_without_dimension, :source => :rater
      has_one :rate_average_without_dimension, -> { where dimension: nil}, :as => :cacheable, :class_name => "RatingCache", :dependent => :destroy

      dimensions.each do |dimension|
        has_many "#{dimension}_rates".to_sym, -> { where dimension: nil }, :as => :rateable, :dependent => :destroy, :class_name => "Rate"
        has_many "#{dimension}_raters".to_sym, :through => "#{dimension}_rates", :source => :rater
        has_one "#{dimension}_average".to_sym, -> { where dimension: nil }, :as => :cacheable, :class_name => "RatingCache", :dependent => :destroy
      end
    end
  end

end

class ActiveRecord::Base
  include Letsrate
end
