require 'uri'
require 'net/http'

module Adam
  
  class Image
    
    @@character_portrait_uri  = "http://image.eveonline.com/Character/"
    @@corporation_logo_uri    = "http://image.eveonline.com/Corporation/"
    @@alliance_logo_uri       = "http://image.eveonline.com/Alliance/"
    
    # Retrieves a character portrait.
    #
    # Parameters:
    # * +options+ - A hash with these keys:
    #   * +id+ - An integer describing an EVE Online character id.
    #   * +size+ - An integer describing what size to retrieve. Valid sizes are 32, 64, 128 or 256.
    def self.character_portrait(options = {})
      id    = options.fetch(:id)
      size  = options.fetch(:size)
      
      raise ArgumentError, "Valid sizes are 32, 64, 128 or 256" unless [32, 64, 128, 256].include?(size)
      
      request(@@character_portrait_uri + "#{id}_#{size}.jpg")
    end
    
    # Retrieves a corporation logo.
    #
    # Parameters:
    # * +options+ - A hash with these keys:
    #   * +id+ - An integer describing an EVE Online character id.
    #   * +size+ - An integer describing what size to retrieve. Valid sizes are 32, 64, 128 or 256.
    def self.corporation_logo(options = {})
      id    = options.fetch(:id)
      size  = options.fetch(:size)
      
      raise ArgumentError, "Valid sizes are 32, 64, 128 or 256" unless [32, 64, 128, 256].include?(size)
      
      request(@@corporation_logo_uri + "#{id}_#{size}.png")
    end
    
    # Retrieves a alliance logo.
    #
    # Parameters:
    # * +options+ - A hash with these keys:
    #   * +id+ - An integer describing an EVE Online character id.
    #   * +size+ - An integer describing what size to retrieve. Valid sizes are 32, 64 or 128.
    def self.alliance_logo(options = {})
      id    = options.fetch(:id)
      size  = options.fetch(:size)
      
      raise ArgumentError, "Valid sizes are 32, 64 or 128" unless [32, 64, 128].include?(size)
      
      request(@@alliance_logo_uri + "#{id}_#{size}.png")
    end
    
    private
    
    # Queries the EVE Online API for data.
    #
    # Parameters:
    # * +uri+ - A string describing the URI to send a request to.
    def self.request(uri)
      uri = URI.parse(uri)
      
      response, body = nil, nil
      Net::HTTP.new(uri.host, uri.port).start do |http|
        tries = 0
        begin
          response, body = http.get("#{uri.path}?#{uri.query}")
        rescue Timeout::Error
          tries += 1
          if tries < 3
            sleep 5
            retry
          end
        end
      end
      
      body
    end
    
  end
  
end