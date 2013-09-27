require 'active_support/concern'
module Letsrate
  extend ActiveSupport::Concern

  def rate(stars, user, dimension=nil)
    dimension = nil if dimension.blank?

    if can_rate? user, dimension
      collection = rates(dimension)
      user_rate = collection.where(rater_id: user).first || collection.new
      user_rate.stars = stars
      user_rate.rater_id ||= user
      user_rate.save!

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
    self.class.allow_rerating? and return true
    user.ratings_given.where(dimension: dimension, rateable_id: id, rateable_type: self.class.name).size.zero?
  end

  def rates(dimension=nil)
    dimension ? self.send("#{dimension}_rates") : rates_without_dimension
  end

  def raters(dimension=nil)
    dimension ? self.send("#{dimension}_raters") : raters_without_dimension
  end

  module ClassMethods
    @@allow_rerating = false

    def letsrate_rater
      has_many :ratings_given, :class_name => "Rate", :foreign_key => :rater_id
    end

    def letsrate_rateable(*dimensions, allow_rerating: false)
      @@allow_rerating = allow_rerating

      has_many :rates_without_dimension, :as => :rateable, :class_name => "Rate", :dependent => :destroy, :conditions => {:dimension => nil}
      has_many :raters_without_dimension, :through => :rates_without_dimension, :source => :rater

      has_one :rate_average_without_dimension, :as => :cacheable, :class_name => "RatingCache",
              :dependent => :destroy, :conditions => {:dimension => nil}


      dimensions.each do |dimension|
        has_many "#{dimension}_rates", :dependent => :destroy,
                                       :conditions => {:dimension => dimension.to_s},
                                       :class_name => "Rate",
                                       :as => :rateable

        has_many "#{dimension}_raters", :through => "#{dimension}_rates", :source => :rater

        has_one "#{dimension}_average", :as => :cacheable, :class_name => "RatingCache",
                                        :dependent => :destroy, :conditions => {:dimension => dimension.to_s}
      end
    end

    def allow_rerating?
      @@allow_rerating
    end
  end

end

class ActiveRecord::Base
  include Letsrate
end
