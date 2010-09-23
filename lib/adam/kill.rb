module Adam
  
  class Kill
    attr_accessor :eve_id, :time, :solar_system, :victim, :involved_parties, :loot
    
    def initialize
      yield self if block_given?
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