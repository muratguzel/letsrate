module Helpers  
  def rating_for(rateable_obj, dimension=nil, options={})                             
 
    if dimension.nil?
      klass = rateable_obj.average
    else             
      klass = rateable_obj.average "#{dimension}"    
    end
    
    if klass.nil?
      avg = 0
    else
      avg = klass.avg
    end
     
    if options[:start].present?
      content_tag :div, "", "data-dimension" => dimension, :class => "star", "data-rating" => avg, 
                            "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name,
                            "data-star-count" => options[:star]           
    else
      content_tag :div, "", "data-dimension" => dimension, :class => "star", "data-rating" => avg, 
                            "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name
    end
  end
     
end

class ActionView::Base
  include Helpers
end