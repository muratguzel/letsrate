module Helpers
  def rating_for(rateable_obj, dimension=nil, options={})

    cached_average = rateable_obj.average dimension

    avg = cached_average ? cached_average.avg : 0

    star = options[:star] || 5

    disable_after_rate = options[:disable_after_rate] || true

    readonly = !(current_user && rateable_obj.can_rate?(current_user, dimension))

    content_tag :div, '', "data-dimension" => dimension, :class => "star", "data-rating" => avg,
                "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name,
                "data-disable-after-rate" => disable_after_rate,
                "data-readonly" => readonly,
                "data-star-count" => star
  end

end

class ActionView::Base
  include Helpers
end
