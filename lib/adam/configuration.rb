module Adam
  
  class Configuration
    
    def initialize(data = {})
      @data = {}
      populate!(data)
    end
    
    def populate!(data)
      data.each do |key, value|
        self[key] = value
      end
    end
    
    def [](key)
      @data[key.to_sym]
    end
    
    def []=(key, value)
      if value.class == Hash
        @data[key.to_sym] = Configuration.new(value)
      else
        @data[key.to_sym] = value
      end
    end
    
    def method_missing(sym, *args)
      if sym.to_s =~ /(.+)=$/
        self[$1] = args.first
      else
        self[sym]
      end
    end
      
  end
  
end