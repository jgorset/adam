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
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 3
      http.read_timeout = 20
      
      request = Net::HTTP::Get.new(uri.path)
      request['user-agent'] = "Adam #{Adam::VERSION}"
      
      tries = 0
      begin
        tries += 1
        response = http.request(request)
      rescue Timeout::Error
        sleep 5 and retry if tries < 3
      end
      
      response.body
    end
    
  end
  
end