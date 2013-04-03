class RaterController < ApplicationController 
  
  def create                                  
    if current_user.present?
      obj = params[:klass].classify.constantize.find(params[:id])
      if params[:dimension].present?
        obj.rate params[:score].to_i, current_user.id, "#{params[:dimension]}", params[:id]
      else
        obj.rate params[:score].to_i, current_user.id, nil, params[:id]
      end
      
      render :json => true 
    else
      render :json => false        
    end
  end                                        
  
  
end
