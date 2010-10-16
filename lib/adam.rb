module Adam
  VERSION = '1.5.1'
  
  autoload :Killmail, 'adam/killmail'
  autoload :KillLog, 'adam/kill_log'
  autoload :Kill, 'adam/kill'
  autoload :Killboard, 'adam/killboard'
  autoload :Image, 'adam/image'
  autoload :Configuration, 'adam/configuration'
  
  CONFIGURATION = Configuration.new(
    :database => {
      :adapter => 'mysql2',
      :username => 'username',
      :password => 'password',
      :name => 'database',
      :host => 'localhost'
    }
  )
  
  def self.configure
    yield CONFIGURATION
  end
  
end

