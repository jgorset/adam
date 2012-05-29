require 'active_record'

unless ActiveRecord::Base.connected?
  ActiveRecord::Base.establish_connection(
    :adapter => Adam::CONFIGURATION.database.adapter,
    :username => Adam::CONFIGURATION.database.username,
    :password => Adam::CONFIGURATION.database.password,
    :database => Adam::CONFIGURATION.database.name,
    :host => Adam::CONFIGURATION.database.host
  )
end

class Moon < ActiveRecord::Base; end