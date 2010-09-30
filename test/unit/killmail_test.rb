$: << File.expand_path(File.dirname(__FILE__) + '/../../lib/') unless $:.include? File.expand_path(File.dirname(__FILE__) + '/../../lib/')

require 'test/unit'
require 'adam'

class KillmailTest < Test::Unit::TestCase
  def test_parse_valid_killmail
    assert_instance_of Adam::Kill, Adam::Killmail.parse(load_killmail('valid_killmail.txt'))
  end
  
  def test_parse_invalid_killmail
    assert_raise Adam::Killmail::ValidationError do
      Adam::Killmail.parse(load_killmail('invalid_killmail.txt'))
    end
  end
  
  private
  
  def load_killmail(filename)
    File.read(File.dirname(__FILE__) + "/../fixtures/killmails/#{filename}")
  end  
end