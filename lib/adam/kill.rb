module Adam
  
  class Kill
    attr_accessor :eve_id, :time, :solar_system, :victim, :involved_parties, :loot
    
    def initialize
      yield self if block_given?
    end
    
    def to_killmail

      killmail = ""
      killmail << time.strftime("%Y.%m.%d %H:%M")
      killmail << "\n"
      killmail << "Victim: #{victim.pilot}\n"
      killmail << "Corp: #{victim.corporation}\n"
      killmail << "Alliance: #{victim.alliance}\n" if victim.alliance
      killmail << "Alliance: Unknown\n" unless victim.alliance
      killmail << "Faction: #{victim.faction}\n" if victim.faction
      killmail << "Faction: NONE\n" unless victim.faction
      killmail << "Destroyed: #{victim.ship}\n"
      killmail << "System: #{solar_system.name}\n"
      killmail << "Security: #{solar_system.security_status.round(2)}\n"
      killmail << "Damage Taken: #{victim.damage_taken}\n"
      killmail << "\n"
      killmail << "Involved parties:\n"
      killmail << "\n"

      involved_parties.each do |involved_party|
        
        case involved_party.type
          
          when "PC"
            killmail << "Name: #{involved_party.pilot} (laid the final blow)\n" if involved_party.final_blow
            killmail << "Name: #{involved_party.pilot}\n" unless involved_party.final_blow
            killmail << "Security: #{involved_party.security_status.round(2)}\n"
            killmail << "Corp: #{involved_party.corporation}\n"
            killmail << "Alliance: #{involved_party.alliance}\n" if involved_party.alliance
            killmail << "Alliance: NONE\n" unless involved_party.alliance
            killmail << "Faction: #{involved_party.faction}\n" if involved_party.faction
            killmail << "Faction: NONE\n" unless involved_party.faction
            killmail << "Ship: #{involved_party.ship}\n"
            killmail << "Weapon: #{involved_party.weapon}\n"
            killmail << "Damage Done: #{involved_party.damage_done}\n"
            killmail << "\n"
            
          when "NPC"
            killmail << "Name: #{involved_party.ship} / #{involved_party.corporation or involved_party.faction} (laid the final blow)\n" if involved_party.final_blow
            killmail << "Name: #{involved_party.ship} / #{involved_party.corporation or involved_party.faction}\n" unless involved_party.final_blow
            killmail << "Damage Done: #{involved_party.damage_done}\n"
            killmail << "\n"
            
        end
        
      end

      killmail << "\n"
      killmail << "\n"

      destroyed_items = loot.select { |l| l.dropped == false }
      unless destroyed_items.empty?
        killmail << "Destroyed items:\n"
        killmail << "\n"
        destroyed_items.each do |loot|
          killmail << "#{loot.name}"
          killmail << ", Qty: #{loot.quantity}" if loot.quantity > 1
          killmail << " (Cargo)" if loot.cargo
          killmail << " (Drone Bay)" if loot.drone_bay
          killmail << "\n"
        end
      end

      dropped_items = loot.select { |l| l.dropped == true }
      unless dropped_items.empty?
        killmail << "Dropped items:\n"
        killmail << "\n"
        dropped_items.each do |loot|
          killmail << "#{loot.name}"
          killmail << ", Qty: #{loot.quantity}" if loot.quantity > 1
          killmail << " (Cargo)" if loot.cargo
          killmail << " (Drone Bay)" if loot.drone_bay
          killmail << "\n"
        end
      end

      killmail
    end
    
  end
  
  class Kill::SolarSystem
    attr_accessor :name, :security_status
    
    def initialize
      yield self if block_given?
    end
    
  end
  
  class Kill::Victim
    attr_accessor :pilot, :corporation, :alliance, :faction, :ship, :damage_taken
    
    def initialize
      yield self if block_given?
    end

  end
  
  class Kill::InvolvedParty
    attr_accessor :type, :pilot, :security_status, :corporation, :alliance, :faction, :ship, :weapon, :damage_done, :final_blow
    
    def initialize
      yield self if block_given?
    end
    
  end
  
  class Kill::Loot
    attr_accessor :name, :quantity, :cargo, :drone_bay, :dropped
    
    def initialize
      yield self if block_given?
    end
  end
  
end