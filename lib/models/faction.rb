require 'active_record'

unless ActiveRecord::Base.connected?
  database_configuration = YAML::load_file(File.dirname(__FILE__) + '/../../config/database.yml')
  ActiveRecord::Base.establish_connection YAML::load_file(File.dirname(__FILE__) + '/../../config/database.yml')
end

class Faction < ActiveRecord::Base; end