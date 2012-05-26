$: << File.expand_path(File.dirname(__FILE__) + '/../../lib/') unless $:.include? File.expand_path(File.dirname(__FILE__) + '/../../lib/')

require 'test/unit'
require 'adam'

class KillTest < Test::Unit::TestCase
  def setup
    Adam::configure do |c|
      c.database.adapter = 'postgresql'
      c.database.username = 'username'
      c.database.password = 'password'
      c.database.name = 'database'
      c.database.host = 'localhost'
    end
  end
  
  def test_digest_is_correct
    assert_equal "6feb01bf9db0813bb7031f93365f853a", Adam::Killmail.parse(load_killmail('valid_killmail.txt')).digest
  end
  
  def test_digest_does_not_change
    assert_equal Adam::Killmail.parse(load_killmail('valid_killmail.txt')).digest, Adam::Killmail.parse(load_killmail('valid_killmail.txt')).digest
  end
  
  def test_reverse_engineers_correctly
    assert_equal load_killmail('valid_killmail.txt'), Adam::Killmail.parse(load_killmail('valid_killmail.txt')).to_killmail
  end
  
  private
  
  def load_killmail(filename)
    File.read(File.dirname(__FILE__) + "/../fixtures/killmails/#{filename}")
  end
end
