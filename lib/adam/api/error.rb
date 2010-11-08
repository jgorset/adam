module Adam
  
  module API
    
    class Error < StandardError
      attr_reader :code, :message
      
      def initialize(code, message)
        @code, @message = code, message
      end
    end
    
  end
  
end