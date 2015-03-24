require 'active_support/concern'
module Letsrate
  extend ActiveSupport::Concern

  def rate(stars, user, dimension=nil, dirichlet_method=false)
    dimension = nil if dimension.blank?

    if can_rate? user, dimension
      rates(dimension).create! do |r|
        r.stars = stars
        r.rater = user
      end
      if dirichlet_method
        update_rate_average_dirichlet(stars, dimension)
      else
        update_rate_average(stars, dimension)
      end
    else
      raise "User has already rated."
    end
  end

  def update_rate_average_dirichlet(stars, dimension=nil)
    ## assumes 5 possible vote categories
    dp = {1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1}
    stars_group = Hash[rates(dimension).group(:stars).count.map{|k,v| [k.to_i,v] }]
    posterior = dp.merge(stars_group){|key, a, b| a + b}
    sum = posterior.map{ |i, v| v }.inject { |a, b| a + b }
    davg = posterior.map{ |i, v| i * v }.inject { |a, b| a + b }.to_f / sum

    if average(dimension).nil?
      RatingCache.create! do |avg|
        avg.cacheable_id = self.id
        avg.cacheable_type = self.class.name
        avg.qty = 1
        avg.avg = davg
        avg.dimension = dimension
      end
    else
      a = average(dimension)
      a.qty = rates(dimension).count
      a.avg = davg
      a.save!(validate: false)
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

  def has_rate?(user, dimension=nil)
    user.ratings_given.where(dimension: dimension, rateable_id: id, rateable_type: self.class.name).size.nonzero?
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
      opts = dimensions.extract_options!
      has_many :rates_without_dimension, :as => :rateable, :class_name => "Rate", :dependent => :destroy, :conditions => {:dimension => nil}
      has_many :raters_without_dimension, :through => :rates_without_dimension, :source => :rater

      has_one :rate_average_without_dimension, :as => :cacheable, :class_name => "RatingCache",
              :dependent => :destroy, :conditions => {:dimension => nil}


      dimensions.each do |dimension|
        has_many "#{dimension}_rates".to_sym, :dependent => :destroy,
                  :conditions => {:dimension => dimension.to_s},
                  :class_name => "Rate",
                  :as => :rateable

        has_many "#{dimension}_raters".to_sym, :through => "#{dimension}_rates", :source => :rater

        has_one "#{dimension}_average", :as => :cacheable, :class_name => "RatingCache",
                    :dependent => :destroy, :conditions => {:dimension => dimension.to_s}
      end

      if opts[:can_change]
        class_eval <<-RUBY, __FILE__, __LINE__+1
            def rate(stars, user, dimension=nil, dirichlet_method=false)
              dimension = nil if dimension.blank?

              if has_rate? user, dimension
                user.ratings_given.where(dimension: dimension, rateable_id: id, rateable_type: self.class.name).first.update_attribute(:stars,stars)
              else
                rates(dimension).create! do |r|
                  r.stars = stars
                  r.rater = user
                end
              end
              if dirichlet_method
                update_rate_average_dirichlet(stars, dimension)
              else
                update_rate_average(stars, dimension)
              end
            end

            def can_rate?(user, dimension=nil)
              true
            end
        RUBY
      end
    end
  end

end

class ActiveRecord::Base
  include Letsrate
end
