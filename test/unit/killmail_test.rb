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
  
  def test_corresponding_kill_object
    kill = Adam::Killmail.parse(load_killmail('valid_killmail.txt'))
    
    assert_equal kill.victim.pilot, "Vik Reddy"
    assert_equal kill.victim.corporation, "The Arrow Project"
    assert_equal kill.victim.alliance, "Morsus Mihi"
    assert_equal kill.victim.faction, false
    assert_equal kill.victim.ship, "Dominix"
    assert_equal kill.solar_system.name, "Y-C3EQ"
    assert_equal kill.solar_system.security_status, 0.0
    assert_equal kill.victim.damage_taken, 62329
    
    assert_equal kill.involved_parties[0].type, "NPC"
    assert_equal kill.involved_parties[0].ship, "Minmatar Control Tower"
    assert_equal kill.involved_parties[0].corporation, "Trux Germani"
    assert_equal kill.involved_parties[0].damage_done, 23743
    
    assert_equal kill.involved_parties[1].type, "PC"
    assert_equal kill.involved_parties[1].pilot, "Aragorn Angelus"
    assert_equal kill.involved_parties[1].security_status, 5.0
    assert_equal kill.involved_parties[1].corporation, "Shade."
    assert_equal kill.involved_parties[1].alliance, "Cry Havoc."
    assert_equal kill.involved_parties[1].faction, false
    assert_equal kill.involved_parties[1].ship, "Hound"
    assert_equal kill.involved_parties[1].weapon, "Caldari Navy Bane Torpedo"
    assert_equal kill.involved_parties[1].damage_done, 3835
    
    assert_equal kill.loot[0].name, "Antimatter Charge L"
    assert_equal kill.loot[0].dropped, false
    assert_equal kill.loot[0].quantity, 37
    
    assert_equal kill.loot[11].name, "Antimatter Charge L"
    assert_equal kill.loot[11].dropped, false
    assert_equal kill.loot[11].quantity, 4322
    assert_equal kill.loot[11].cargo, true
  end
  
  private
  
  def load_killmail(filename)
    File.read(File.dirname(__FILE__) + "/../fixtures/killmails/#{filename}")
  end  
end