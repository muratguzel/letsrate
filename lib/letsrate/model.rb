require 'active_support/concern'
module Letsrate
  extend ActiveSupport::Concern

  def rate(stars, user_id, dimension=nil)
    if can_rate? user_id, dimension
      rates(dimension).build do |r|
        r.stars = stars
        r.rater_id = user_id
        r.save!
      end
      update_rate_average(stars, dimension)
    else
      raise "User has already rated."
    end
  end

  def update_rate_average(stars, dimension=nil)
    if average(dimension).nil?
      RatingCache.create do |avg|
        avg.cacheable_id = self.id
        avg.cacheable_type = self.class.name
        avg.avg = stars
        avg.qty = 1
        avg.dimension = dimension
        avg.save!
      end
    else
      a = average(dimension)
      a.avg = (a.avg*a.qty + stars) / (a.qty+1)
      a.qty = a.qty + 1
      a.save!
    end
  end

  def average(dimension=nil)
    if dimension.nil?
      self.send "rate_average_without_dimension"
    else
      self.send "#{dimension}_average"
    end
  end

  def can_rate?(user_id, dimension=nil)
    val = self.connection.select_value("select count(*) as cnt from rates where rateable_id=#{self.id} and rateable_type='#{self.class.name}' and rater_id=#{user_id} and dimension='#{dimension}'").to_i
    if val == 0
      true
    else
      false
    end
  end

  def rates(dimension=nil)
    if dimension.nil?
      self.send "rates_without_dimension"
    else
      self.send "#{dimension}_rates"
    end
  end

  def raters(dimension=nil)
    if dimension.nil?
      self.send "raters_without_dimension"
    else
      self.send "#{dimension}_raters"
    end
  end

  module ClassMethods

    def letsrate_rater
      has_many :ratings_given, :class_name => "Rate", :foreign_key => :rater_id
    end

    def letsrate_rateable(*dimensions)
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
  end

end

class ActiveRecord::Base
  include Letsrate
end
