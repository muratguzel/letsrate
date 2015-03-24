module Helpers

  # show rate widget
  # @options[:readonly] show widget in read only mode
  # @options[:disable_after_rate] disable widget after rate
  def rating_for(rateable_obj, dimension=nil, options={})

    cached_average = rateable_obj.average dimension

    avg = cached_average ? cached_average.avg : 0

    star = options[:star] || 5

    disable_after_rate = options[:disable_after_rate] || true

    readonly = !(current_user && rateable_obj.can_rate?(current_user, dimension))
    # now we can force readonly attribute
    readonly = options[:readonly] || readonly unless readonly

    content_tag :div, '', "data-dimension" => dimension, :class => "star", "data-rating" => avg,
                "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name,
                "data-disable-after-rate" => disable_after_rate,
                "data-readonly" => readonly,
                "data-star-count" => star
  end

  # show rate widget for user
  # @options[:readonly] show widget in read only mode
  # @options[:disable_after_rate] disable widget after rate
  def rating_for_user(rateable_obj, rating_user, dimension = nil, options = {})
    @object = rateable_obj
    @user = rating_user
    @rating = Rate.find_by_rater_id_and_rateable_id_and_dimension(@user.id, @object.id, dimension)
    stars = @rating ? @rating.stars : 0
    stars_count = options[:stars_count] || stars
    disable_after_rate = options[:disable_after_rate] || false

    readonly= options[:readonly] || false
    if disable_after_rate
      readonly = current_user.present? ? !rateable_obj.can_rate?(current_user, dimension) : true
    end

    content_tag :div, '', "data-dimension" => dimension, :class => "star", "data-rating" => stars,
                "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name,
                "data-disable-after-rate" => disable_after_rate,
                "data-readonly" => readonly,
                "data-star-count" => stars_count
  end

end

class ActionView::Base
  include Helpers
end
