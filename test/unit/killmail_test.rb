$: << File.expand_path(File.dirname(__FILE__) + '/../../lib/') unless $:.include? File.expand_path(File.dirname(__FILE__) + '/../../lib/')

require 'test/unit'
require 'adam'

class KillmailTest < Test::Unit::TestCase
  def setup
    Adam::configure do |c|
      c.database.adapter = 'postgresql'
      c.database.username = 'username'
      c.database.password = 'password'
      c.database.name = 'database'
      c.database.host = 'localhost'
    end
  end

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
    
    assert_equal "Vik Reddy", kill.victim.pilot
    assert_equal "The Arrow Project", kill.victim.corporation
    assert_equal "Morsus Mihi", kill.victim.alliance
    assert_equal nil, kill.victim.faction
    assert_equal "Dominix", kill.victim.ship
    assert_equal "Y-C3EQ", kill.solar_system.name
    assert_equal 0.0, kill.solar_system.security_status
    assert_equal 62329, kill.victim.damage_taken
    
    assert_equal :NPC, kill.involved_parties[0].type
    assert_equal "Minmatar Control Tower", kill.involved_parties[0].ship
    assert_equal "Trux Germani", kill.involved_parties[0].corporation
    assert_equal 23743, kill.involved_parties[0].damage_done
    
    assert_equal :PC, kill.involved_parties[1].type
    assert_equal "Aragorn Angelus", kill.involved_parties[1].pilot
    assert_equal 5.0, kill.involved_parties[1].security_status
    assert_equal "Shade.", kill.involved_parties[1].corporation
    assert_equal "Cry Havoc.", kill.involved_parties[1].alliance
    assert_equal nil, kill.involved_parties[1].faction
    assert_equal "Hound", kill.involved_parties[1].ship
    assert_equal "Caldari Navy Bane Torpedo", kill.involved_parties[1].weapon
    assert_equal 3835, kill.involved_parties[1].damage_done
    
    assert_equal "Antimatter Charge L", kill.loot[0].name
    assert_equal false, kill.loot[0].dropped
    assert_equal 37, kill.loot[0].quantity
    
    assert_equal "Antimatter Charge L", kill.loot[11].name
    assert_equal false, kill.loot[11].dropped
    assert_equal 4322, kill.loot[11].quantity
    assert_equal :cargo_bay, kill.loot[11].location
    
    assert_equal "Ocular Filter - Improved", kill.loot[16].name
    assert_equal false, kill.loot[16].dropped
    assert_equal :implant, kill.loot[16].location
    
    assert_equal "Exotic Dancers, Female", kill.loot[17].name
    assert_equal false, kill.loot[17].dropped
    assert_equal 2, kill.loot[17].quantity
    assert_equal :cargo_bay, kill.loot[17].location
  end
  
  def test_corresponding_kill_structure_object
    kill = Adam::Killmail.parse(load_killmail('valid_structure_killmail.txt'))
    
    assert_equal "Essence Enterprises", kill.victim.corporation
    assert_equal nil, kill.victim.alliance
    assert_equal nil, kill.victim.faction
    assert_equal "Explosion Dampening Array", kill.victim.ship
    assert_equal "Noghere VII - Moon 16", kill.victim.moon
    assert_equal "Noghere", kill.solar_system.name
    assert_equal 0.7, kill.solar_system.security_status
    assert_equal 17085, kill.victim.damage_taken
    
    assert_equal :PC, kill.involved_parties[0].type
    assert_equal "Sisko Urso", kill.involved_parties[0].pilot
    assert_equal 3.2, kill.involved_parties[0].security_status
    assert_equal "Rage For Order", kill.involved_parties[0].corporation
    assert_equal "nihil-obstat", kill.involved_parties[0].alliance
    assert_equal nil, kill.involved_parties[0].faction
    assert_equal "Maelstrom", kill.involved_parties[0].ship
    assert_equal "Maelstrom", kill.involved_parties[0].weapon
    assert_equal 10102, kill.involved_parties[0].damage_done
    
    assert_equal [], kill.loot
  end
  
  private
  
  def load_killmail(filename)
    File.read(File.dirname(__FILE__) + "/../fixtures/killmails/#{filename}")
  end  
end
