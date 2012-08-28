# Rateit Rating Gem  

Provides the best way to add rating capabilites to your Rails application with jQuery Raty plugin.

## Repository

Find it at [github.com/muratguzel/rateit](github.com/muratguzel/rateit)

## Instructions

### Install

You can add the rateit gem into your Gemfile

	gem 'rateit'
	
### Generate

	rails g rateit User

The generator takes one argument which is the name of your existing UserModelName. This is necessary to bind the user and rating datas.
Also the generator copies necessary files (jquery raty plugin files, star icons and javascripts)

Example: 

Suppose you will have a devise user model which name is User. The generator should be like below

	rails g devise:install
	rails g devise user
	rails g rateit user # => This is rateit generator. 
   
This generator will create Rate and RatingCache models and link to your user model. 

### Prepare

I suppose you have a car model 

	rails g model car name:string

You should add the rateit_rateable function with its dimension option.

	class Car < ActiveRecord::Base
		rateit_rateable :dimensions => [:speed, :engine, :price]
	end                                                         
	
Then you need to add a call rateit_rater in the user model. 

	class User < ActiveRecord::Base
		ratme_rater
	end   
	
	
### Using

There is a helper method which name is rating_for to add the star links. By default rating_for will display the average rating and accept the 
new rating value from authenticated user. 

	#show.html.erb -> /cars/1
	
	Speed : <%= rating_for @car, "speed" %>
	Engine : <%= rating_for @car, "engine" %>
	Price : <%= rating_for @car, "price" %>
   
### Important 

By default rating_for tries to call current_user method as the rater instance in the rater_controller.rb file. You can change the current_user method 
as you will.

	#rater_controller.rb
	
	def create                                  
    	if current_user.present?
	      obj = eval "#{params[:klass]}.find(#{params[:id]})"     
	      if params[:dimension].present?
	        obj.rate params[:score].to_i, current_user.id, "#{params[:dimension]}"       
	      else
	        obj.rate params[:score].to_i, current_user.id 
	      end

	      render :json => true 
	    else
	      render :json => false        
	    end
	end   
     
## Feedback
If you find bugs please open a ticket at [github.com/muratguzel/rateit/issues](github.com/muratguzel/rateit/issues)
	
	