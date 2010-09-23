require 'active_record'

database_configuration = YAML::load_file(File.dirname(__FILE__) + '/../config/database.yml')
ActiveRecord::Base.establish_connection(database_configuration)

class Item < ActiveRecord::Base; end
class SolarSystem < ActiveRecord::Base; end