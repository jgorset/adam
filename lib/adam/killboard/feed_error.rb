module Adam
  
  class Killboard
    
    class FeedError < RuntimeError
      attr_reader :source
    
      def initialize(source)
        @source = source
      end
    end
  
  end
  
end
