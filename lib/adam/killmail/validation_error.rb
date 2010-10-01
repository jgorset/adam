module Adam
  
  module Killmail
    
    class ValidationError < RuntimeError
      attr_reader :source
    
      def initialize(source = false)
        @source = source
      end
    end
    
  end

end
