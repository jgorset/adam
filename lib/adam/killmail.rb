require "adam/killmail/validation_error"

require "time"

module Adam
  
  module Killmail
    
    extend self
    
    def parse(source)

      # Normalize line endings
      source.encode! :universal_newline => true

      kill = Adam::Kill.new do |kill|
  
        time = source[/([0-9]{4}\.[0-9]{2}\.[0-9]{2} [0-9]{2}:[0-9]{2})/, 1] or raise ValidationError.new(source), "Time malformed"
        time = Time.parse(time + " UTC")
      
        kill.time = time
        
        kill.solar_system = Adam::Kill::SolarSystem.new do |ss|
          ss.name             = source[/System: (.+)/, 1] or raise ValidationError.new(source), "Solar system malformed"
          ss.security_status  = source[/Security: ([\.0-9]+)/, 1].to_f or raise ValidationError.new(source), "Solar system security malformed"
        end
  
        kill.victim = Adam::Kill::Victim.new do |v|
          v.pilot         = source[/Victim: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Victim pilot malformed"
          v.corporation   = source[/Corp: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Victim corporation malformed"
          v.alliance      = source[/Alliance: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Victim alliance malformed"
          v.faction       = source[/Faction: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Victim faction malformed"
          v.ship          = source[/Destroyed: (.+)/, 1] or raise ValidationError.new(source), "Victim ship malformed"
          v.damage_taken  = source[/Damage Taken: ([0-9]+)/, 1].to_i or raise ValidationError.new(source), "Victim damage taken malformed"
      
          # Set pilot to nil if it's a moon
          v.pilot = nil if v.pilot =~ /[a-zA-Z0-9\- ]+ - Moon [0-9]+/
        
          # Convert alliance/faction from "unknown" or "none" to false
          v.alliance = false if v.alliance =~ /unknown|none/i
          v.faction = false if v.faction =~ /unknown|none/i
        end
        
        kill.involved_parties = []
        
        involved_parties = source[/Involved parties:\n\n(((.+\n){8}\n|(.+\n){2}\n)*)/, 1] or raise ValidationError.new(source), "Involved parties malformed"
        involved_parties.split("\n\n").each_with_index do |snippet, i|
          
          lines = 0 and snippet.each_line { |line| lines += 1 }
          
          case lines
            
            when 8
              kill.involved_parties << Adam::Kill::InvolvedParty.new do |ip|
                ip.type                   = "PC"
                ip.pilot                  = snippet[/Name: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Involved party #{i+1} pilot malformed"
                ip.security_status        = snippet[/Security: ([\-\.0-9]+)/, 1].to_f or raise ValidationError.new(source), "Involved party #{i+1} security malformed"
                ip.corporation            = snippet[/Corp: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Involved party #{i+1} corporation malformed"
                ip.alliance               = snippet[/Alliance: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Involved party #{i+1} alliance malformed"
                ip.faction                = snippet[/Faction: ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Involved party #{i+1} faction malformed"
                ip.ship                   = snippet[/Ship: (.+)/, 1] or raise ValidationError.new(source), "Involved party #{i+1} ship malformed"
                ip.weapon                 = snippet[/Weapon: (.+)/, 1] or raise ValidationError.new(source), "Involved party #{i+1} weapon malformed"
                ip.damage_done            = (snippet[/Damage Done: ([0-9]+)/, 1] or raise ValidationError.new(source), "Involved party #{i+1} damage malformed").to_i
                ip.final_blow             = snippet =~ /\(laid the final blow\)/ ? true : false
                
                # Convert alliance/faction from "unknown" or "none" to false
                ip.alliance = false if ip.alliance =~ /unknown|none/i
                ip.faction = false if ip.faction =~ /unknown|none/i
              end
                
            when 2
              kill.involved_parties << Adam::Kill::InvolvedParty.new do |ip|
                ip.type                   = "NPC"
                ip.ship                   = snippet[/Name: ([^\/]+)/, 1] or raise ValidationError.new(source), "Involved party #{i+1} ship malformed"
                ip.damage_done            = (snippet[/Damage Done: ([0-9]+)/, 1] or raise ValidationError.new(source), "Involved party #{i+1} damage malformed").to_i
                ip.final_blow             = snippet =~ /\(laid the final blow\)/ ? true : false
                
                # Determine whether allegiance is a faction or a corporation
                allegiance = snippet[/Name: [^\/]+ \/ ([a-zA-Z0-9]{1}[a-zA-Z0-9'. -]{1,48}[a-zA-Z0-9.]{1})/, 1] or raise ValidationError.new(source), "Involved party #{i+1} allegiance malformed"
                if allegiance =~ /^(Caldari State|Minmatar Republic|Amarr Empire|Gallente Federation|Jove Empire|CONCORD Assembly|Ammatar Mandate|Khanid Kingdom|The Syndicate|Guristas Pirates|Angel Cartel|The Blood Raider Covenant|The InterBus|ORE|Thukker Tribe|The Servant Sisters of EVE|The Society|Mordu's Legion Command|Sansha's Nation|Serpentis)$/
                  ip.faction = allegiance
                elsif allegiance == 'Unknown'
                  ip.corporation = false
                else
                  ip.corporation = allegiance
                end
              end
              
          end
          
        end
        
        kill.loot = []
        
        if source =~ /Destroyed items:/
          source[/Destroyed items:\n\n(((.+)\n)*)/, 1].split("\n").each_with_index do |snippet, i|
            loot = Adam::Kill::Loot.new do |l|
              l.name       = snippet[/([^,\(\)]+)/, 1] or raise ValidationError.new(source), "Destroyed item #{i+1} name malformed"
              l.quantity   = snippet =~ /Qty: ([0-9]+)/ ? snippet[/Qty: ([0-9]+)/, 1].to_i : 1
              l.cargo      = snippet[/(Cargo)/] ? true : false
              l.drone_bay  = snippet[/(Drone Bay)/] ? true : false
              l.dropped    = false
            end
            existing_loot = kill.loot.select { |el| el.name.eql?(loot.name) and el.cargo.eql?(loot.cargo) and el.drone_bay.eql?(loot.drone_bay) and el.dropped.eql?(loot.dropped) }[0]
            existing_loot ? existing_loot.quantity += loot.quantity : kill.loot << loot
          end
        end
        
        if source =~ /Dropped items:/
          source[/Dropped items:\n\n(((.+)\n)*)/, 1].split("\n").each_with_index do |snippet, i|
            loot = Adam::Kill::Loot.new do |l|
              l.name       = snippet[/([^,\(\)]+)/, 1] or raise ValidationError.new(source), "Dropped item #{i+1} name malformed"
              l.quantity   = snippet =~ /Qty: ([0-9]+)/ ? snippet[/Qty: ([0-9]+)/, 1].to_i : 1
              l.cargo      = snippet[/(Cargo)/] ? true : false
              l.drone_bay  = snippet[/(Drone Bay)/] ? true : false
              l.dropped    = true
            end
            existing_loot = kill.loot.select { |el| el.name.eql?(loot.name) and el.cargo.eql?(loot.cargo) and el.drone_bay.eql?(loot.drone_bay) and el.dropped.eql?(loot.dropped) }[0]
            existing_loot ? existing_loot.quantity += loot.quantity : kill.loot << loot
          end
        end
        
      end
            
      return kill
    end
    
  end
  
end