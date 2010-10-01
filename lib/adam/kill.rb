require 'digest'

module Adam
  
  # Instances of the Kill class represent a kill in the EVE Online universe.
  #
  # Accessors:
  # * +eve_id+ - The EVE ID of the killmail. This is only populated if the kill was derived from a kill log.
  # * +time+ - A time object set to the time of the kill.
  # * +solar_system+ - A solar system object (see the SolarSystem class).
  # * +victim+ - A victim object (see the Victim class).
  # * +solar_system+ - A solar system object (see the SolarSystem class).
  # * +involved_parties+ - An array of involved party objects (see the InvolvedParty class).
  # * +loot+ - An array of loot objects (see the Loot class).
  class Kill
    attr_accessor :eve_id, :time, :solar_system, :victim, :involved_parties, :loot
    
    def initialize
      yield self if block_given?
    end
    
    # Reverse-engineer the killmail. This is particularly useful if it
    # was originally derived from a kill log.
    def to_killmail

      killmail = ""
      killmail << time.strftime("%Y.%m.%d %H:%M")
      killmail << "\n"
      killmail << "Victim: #{victim.pilot}\n"
      killmail << "Corp: #{victim.corporation}\n"
      killmail << "Alliance: #{victim.alliance}\n" if victim.alliance
      killmail << "Alliance: Unknown\n" if victim.alliance.nil?
      killmail << "Faction: #{victim.faction}\n" if victim.faction
      killmail << "Faction: NONE\n" if victim.faction.nil?
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
            killmail << "Alliance: NONE\n" if involved_party.alliance.nil?
            killmail << "Faction: #{involved_party.faction}\n" if involved_party.faction
            killmail << "Faction: NONE\n" if involved_party.faction.nil?
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

      destroyed_items = loot.select { |l| l.dropped == false }
      unless destroyed_items.empty?
        killmail << "\n"
        killmail << "Destroyed items:\n"
        killmail << "\n"
        destroyed_items.each do |loot|
          killmail << "#{loot.name}"
          killmail << ", Qty: #{loot.quantity}" if loot.quantity > 1
          killmail << " (Cargo)" if loot.cargo_hold
          killmail << " (Drone Bay)" if loot.drone_bay
          killmail << "\n"
        end
      end

      dropped_items = loot.select { |l| l.dropped == true }
      unless dropped_items.empty?
        killmail << "\n"
        killmail << "Dropped items:\n"
        killmail << "\n"
        dropped_items.each do |loot|
          killmail << "#{loot.name}"
          killmail << ", Qty: #{loot.quantity}" if loot.quantity > 1
          killmail << " (Cargo)" if loot.cargo_hold
          killmail << " (Drone Bay)" if loot.drone_bay
          killmail << "\n"
        end
      end

      killmail
    end
    
    alias_method :to_s, :to_killmail
    
    # Calculates the message digest of the killmail.
    def digest
      string = "#{time}#{victim.pilot}#{victim.ship}#{solar_system.name}#{victim.damage_taken}"
      involved_parties.sort! { |x, y| x.damage_done <=> y.damage_done }
      involved_parties.each { |p| string << "#{p.pilot}#{p.damage_done}" }
      Digest::MD5.hexdigest(string)
    end
    
  end
  
  # Instances of the SolarSystem class represent a solar system in the EVE universe.
  #
  # Accessors:
  # * +name+ - A string describing the name of the solar system.
  # * +security_status+ - A floating-point number describing the security status of the solar system.
  class Kill::SolarSystem
    attr_accessor :name, :security_status
    
    def initialize
      yield self if block_given?
    end
  end
  
  # Instances of the Kill class represent a victim of a kill.
  #
  # Accessors:
  # * +pilot+ - A string describing the name of the pilot.
  # * +corporation+ - A string describing the name of the corporation the pilot is enrolled in.
  # * +alliance+ - A string describing the name of the alliance the corporation is a member of. May be +nil+ if the corporation is not in an alliance.
  # * +faction+ - A string describing the name of the faction the pilot is involved in. May be +nil+ if the pilot is not in a faction.
  # * +ship+ - A string describing the name of the ship that was destroyed.
  # * +damage_taken+ - An integer describing damage taken.
  class Kill::Victim
    attr_accessor :pilot, :corporation, :alliance, :faction, :ship, :damage_taken
    
    def initialize
      yield self if block_given?
    end
  end
  
  # Instances of the InvolvedParty class represent an involved party in a kill.
  #
  # Accessors:
  # * +type+ - A symbol describing whether the pilot was player-controlled (:PC) or non-player controlled (:NPC).
  # * +pilot+ - A string describing the name of the pilot. For NPCs, this is +nil+.
  # * +security_status+ - A floating-point number describing the security status of the pilot. For NPCs, this is +nil+.
  # * +corporation+ - A string describing the name of the corporation the pilot is enrolled in. For NPCs, this may be nil.
  # * +alliance+ - A string describing the name of the alliance the corporation is a member of. May be +nil+ if the corporation is not in an alliance.
  # * +faction+ - A string describing the name of the faction the pilot is involved in. May be +nil+ if the pilot is not in a faction.
  # * +ship+ - A string describing the name of the ship that the pilot was flying.
  # * +weapon+ - A string describing the name of the weapon that was last fired by this pilot.
  # * +damage_done+ - An integer describing damage done by this pilot.
  # * +final_blow+ - A boolean describing whether or not this pilot made the final blow.
  class Kill::InvolvedParty
    attr_accessor :type, :pilot, :security_status, :corporation, :alliance, :faction, :ship, :weapon, :damage_done, :final_blow
    
    def pc?
      type == :PC
    end
    
    def npc?
      type == :NPC
    end
    
    def initialize
      yield self if block_given?
    end
  end
  
  # Instances of the Loot class represent a piece of loot of a kill.
  #
  # Accessors:
  # * +name+ - A string describing the name of the item.
  # * +quantity+ - An integer describing the quantity of the item.
  # * +cargo_hold+ - A boolean describing whether or not this item was in the cargo hold.
  # * +drone_bay+ - A boolean describing whether or not this item was in the drone bay.
  # * +dropped+ - A boolean describing whether or not this item was dropped.
  class Kill::Loot
    attr_accessor :name, :quantity, :cargo_hold, :drone_bay, :dropped
    
    def cargo_hold?
      cargo_hold
    end
    
    def dropped?
      dropped
    end
    
    def initialize
      yield self if block_given?
    end
  end
  
end
