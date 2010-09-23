$: << File.expand_path(File.dirname(__FILE__)) unless $:.include?(File.expand_path(File.dirname(__FILE__)))

module Adam
  VERSION = '1.0.0'
  
  autoload :Killmail, 'adam/killmail'
  autoload :KillLog, 'adam/kill_log'
  autoload :Kill, 'adam/kill'
  autoload :Killboard, 'adam/killboard'
end
