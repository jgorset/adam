$: << File.expand_path(File.dirname(__FILE__) + '/../../lib/') unless $:.include? File.expand_path(File.dirname(__FILE__) + '/../../lib/')

require 'test/unit'
require 'adam'

class KillLogTest < Test::Unit::TestCase
  def setup
    Adam::configure do |c|
      c.database.adapter = 'postgresql'
      c.database.username = 'username'
      c.database.password = 'password'
      c.database.name = 'database'
      c.database.host = 'localhost'
    end
  end

  def test_parse_valid_kill_log
    assert_instance_of Array, Adam::KillLog.parse(load_kill_log('valid_kill_log.xml'))
  end
  
  private
  
  def load_kill_log(filename)
    File.read(File.dirname(__FILE__) + "/../fixtures/kill_logs/#{filename}")
  end  
end
