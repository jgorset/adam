require 'adam/kill_log/validation_error'

SolarSystem rescue require 'models/solar_system'
Item rescue require 'models/item'
Faction rescue require 'models/faction'

require 'hpricot'
require 'time'

module Adam
  
  module KillLog
   
    extend self
    
    # Parses a kill log and returns an array of Kill objects.
    #
    # Parameters:
    # * +source+ - A kill log as returned by the EVE Online API.
    def parse(source)
      document = Hpricot.XML(source)

      kill_logs = []
      document.search("//rowset[@name=kills]/row").each do |kill_log|
        begin
          kill_logs << parse_single(kill_log)
        rescue ValidationError
          next
        end
      end

      kill_logs
    end

    private
    
    # Parses a single element of a kill log.
    #
    # Parameters:
    # * +kill_element+ - A single kill element.
    def parse_single(kill_element)
      
      Adam::Kill.new do |k|

        k.eve_id   = kill_element['killID'].to_i
        k.time     = Time.parse(kill_element['killTime']).utc

        k.solar_system = Adam::Kill::SolarSystem.new do |ss|
          ss.name             = SolarSystem.find(kill_element['solarSystemID']).name
          ss.security_status  = SolarSystem.find(kill_element['solarSystemID']).security_status
        end
    
        k.victim = Adam::Kill::Victim.new do |v|
          victim_element = kill_element.at('/victim')
          
          raise ValidationError, "Victim pilot no longer exists" if victim_element['characterName'].empty?
          raise ValidationError, "Victim corporation no longer exists" if victim_element['corporationName'].empty?
          raise ValidationError, "Victim alliance no longer exists" if victim_element['allianceName'].empty?
          
          v.pilot         = victim_element['characterName']
          v.corporation   = victim_element['corporatioNname']
          v.alliance      = victim_element['allianceName'] == '' ? nil : victim_element['allianceName']
          v.faction       = victim_element['factionName'] == '' ? nil: victim_element['factionName']
          v.ship          = Item.find(victim_element['shipTypeID']).name
          v.damage_taken  = victim_element['damageTaken'].to_i
        end

        k.involved_parties = []
        kill_element.search('/rowset[@name=attackers]/row').each do |involved_party_element|
          
          k.involved_parties << Adam::Kill::InvolvedParty.new do |ip|
            raise ValidationError, "Involved party pilot no longer exists" if involved_party_element['characterName'].empty?
            raise ValidationError, "Involved party corporation no longer exists" if involved_party_element['corporationName'].empty?
            raise ValidationError, "Involved party alliance no longer exists" if involved_party_element['allianceName'].empty?
            
            ip.type             = involved_party_element['characterName'].empty? ? :NPC : :PC
            ip.pilot            = involved_party_element['characterName'] unless involved_party_element['characterName'].empty?
            ip.corporation      = involved_party_element['corporationName']
            ip.alliance         = involved_party_element['allianceName'] == '' ? nil : involved_party_element['allianceName']
            ip.faction          = involved_party_element['factionName'] == '' ? nil : involved_party_element['factionName']
            ip.security_status  = involved_party_element['securityStatus'].to_f
            ip.ship             = Item.find(involved_party_element['shipTypeID']).name
            ip.weapon           = Item.find(involved_party_element['weaponTypeID']).name
            ip.damage_done      = involved_party_element['damageDone'].to_i
            ip.final_blow       = involved_party_element['finalblow'] == '1' ? true : false
          end
          
        end
        
        k.loot = []
        kill_element.search('/rowset[@name=items]/row').each do |loot_element|
          if loot_element['qtyDropped'].to_i > 0
            k.loot << Adam::Kill::Loot.new do |l|
              l.name           = Item.find(loot_element['typeID']).name
              l.quantity       = loot_element['qtyDropped'].to_i
              l.location       = :cargo_bay if loot_element['flag'] == '5'
              l.location       = :drone_bay if loot_element['flag'] == '87'
              l.location       = :implant   if loot_element['flag'] == '89'
              l.location       = :copy      if loot_element['singleton'] == '2'
              l.dropped        = true
            end
          end

          if loot_element['qtyDestroyed'].to_i > 0
            k.loot << Adam::Kill::Loot.new do |l|
              l.name           = Item.find(loot_element['typeID']).name
              l.quantity       = loot_element['qtyDestroyed'].to_i
              l.location       = :cargo_bay if loot_element['flag'] == '5'
              l.location       = :drone_bay if loot_element['flag'] == '87'
              l.location       = :implant   if loot_element['flag'] == '89'
              l.location       = :copy      if loot_element['singleton'] == '2'
              l.dropped        = false
            end
          end
        end

      end

    end
   
  end
  
end
