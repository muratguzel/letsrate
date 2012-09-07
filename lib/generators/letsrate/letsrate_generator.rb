require 'rails/generators/migration'
class LetsrateGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  
  source_root File.expand_path('../templates', __FILE__)      
                                                       
  desc "copying jquery.raty files to assets directory ..."
  def copying
    copy_file 'jquery.raty.js', 'app/assets/javascripts/jquery.raty.js'
    copy_file 'star-on.png', 'app/assets/images/star-on.png'
    copy_file 'star-off.png', 'app/assets/images/star-off.png'
    copy_file 'star-half.png', 'app/assets/images/star-half.png'
    copy_file 'letsrate.js', 'app/assets/javascripts/letsrate.js.erb'
    copy_file 'rater_controller.rb', 'app/controllers/rater_controller.rb'
  end         
  
  desc "model is creating..."
  def create_model     
    model_file = File.join('app/models', "#{file_path}.rb")
    raise "User model (#{model_file}) must exits." unless File.exists?(model_file)
    class_collisions 'Rate'
    template 'model.rb', File.join('app/models', "rate.rb")    
    template 'cache_model.rb', File.join('app/models', "rating_cache.rb")
  end                                                                           
  
  def add_rate_path_to_route
    route "match '/rate' => 'rater#create', :as => 'rate'"
  end

  desc "cacheable rating average migration is creating ..."
  def create_cacheable_migration
    migration_template "cache_migration.rb", "db/migrate/create_rating_caches.rb"
  end
         
  desc "migration is creating ..."
  def create_migration
    migration_template "migration.rb", "db/migrate/create_rates.rb"    
  end   
  
  
  private 
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S%L")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end    
  end
end