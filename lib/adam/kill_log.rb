require 'adam/kill_log/validation_error'
require 'models' unless defined?(SolarSystem) and defined?(Item)

require 'hpricot'
require 'time'

module Adam
  
  module KillLog
   
    extend self
   
    def parse(source)
      document = Hpricot(source)

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
    
    def parse_single(kill_element)

      kill = Adam::Kill.new do |kill|

        kill.eve_id   = kill_element['killid'].to_i
        kill.time     = Time.parse(kill_element['killtime']).utc

        kill.solar_system = Adam::Kill::SolarSystem.new do |ss|
          ss.name             = SolarSystem.find(kill_element['solarsystemid']).name
          ss.security_status  = SolarSystem.find(kill_element['solarsystemid']).security_status
        end
    
        kill.victim = Adam::Kill::Victim.new do |v|
          victim_element = kill_element.at('/victim')
          
          raise ValidationError, "Victim pilot no longer exists" if victim_element['charactername'].empty?
          raise ValidationError, "Victim corporation no longer exists" if victim_element['corporationname'].empty?
          raise ValidationError, "Victim alliance no longer exists" if victim_element['alliancename'].empty?
          
          v.pilot         = victim_element['charactername']
          v.corporation   = victim_element['corporationname']
          v.alliance      = victim_element['alliancename'] == '' ? false : victim_element['alliancename']
          v.faction       = victim_element['factionname'] == '' ? false: victim_element['factionname']
          v.ship          = Item.find(victim_element['shiptypeid']).name
          v.damage_taken  = victim_element['damagetaken'].to_i
        end

        kill.involved_parties = []
        kill_element.search('/rowset[@name=attackers]/row').each do |involved_party_element|
          
          kill.involved_parties << Adam::Kill::InvolvedParty.new do |ip|
            raise ValidationError, "Involved party pilot no longer exists" if involved_party_element['charactername'].empty?
            raise ValidationError, "Involved party corporation no longer exists" if involved_party_element['corporationname'].empty?
            raise ValidationError, "Involved party alliance no longer exists" if involved_party_element['alliancename'].empty?
            
            ip.type             = involved_party_element['charactername'].empty? ? 'NPC' : 'PC'
            ip.pilot            = involved_party_element['charactername'] unless involved_party_element['charactername'].empty?
            ip.corporation      = involved_party_element['corporationname']
            ip.alliance         = involved_party_element['alliancename'] == '' ? false : involved_party_element['alliancename']
            ip.faction          = involved_party_element['factionname'] == '' ? false : involved_party_element['factionname']
            ip.security_status  = involved_party_element['securitystatus'].to_f
            ip.ship             = Item.find(involved_party_element['shiptypeid']).name
            ip.weapon           = Item.find(involved_party_element['weapontypeid']).name
            ip.damage_done      = involved_party_element['damagedone'].to_i
            ip.final_blow       = involved_party_element['finalblow'] == '1' ? true : false
          end
          
        end
        
        kill.loot = []
        kill_element.search('/rowset[@name=items]/row').each do |loot_element|
          if loot_element['qtydropped'].to_i > 0
            kill.loot << Adam::Kill::Loot.new do |l|
              l.name           = Item.find(loot_element['typeid']).name
              l.quantity       = loot_element['qtydropped'].to_i
              l.cargo          = loot_element['flag'] == '5' ? true : false
              l.drone_bay      = loot_element['flag'] == '87' ? true : false
              l.dropped        = true
            end
          end

          if loot_element['qtydestroyed'].to_i > 0
            kill.loot << Adam::Kill::Loot.new do |l|
              l.name           = Item.find(loot_element['typeid']).name
              l.quantity       = loot_element['qtydropped'].to_i
              l.cargo          = loot_element['flag'] == '5' ? true : false
              l.drone_bay      = loot_element['flag'] == '87' ? true : false
              l.dropped        = false
            end
          end
        end

      end

      return kill
    end
   
  end
  
end