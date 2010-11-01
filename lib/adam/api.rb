require 'uri'
require 'net/http'
require 'hpricot'
require 'ostruct'

module Adam
  
  class API
    
    # Queries the API method described by +path+.
    def self.query(path)
      data = request(path)
      self.parse(data)
    end
    
    private
    
    # Parses an API response.
    #
    # Parameters:
    # * +xml+ - A string with the API response.
    def self.parse(xml)
      xml = Hpricot.XML(xml.gsub!(/\n+|\r+/, '').gsub!(/(>)\s*(<)/, '\1\2'))
      
      
      hash = node_to_hash(xml.at('/eveapi/result'))
      
      p hash
      
    end
    
    private
    
    # Returns an element's hash equivalent.
    #
    # Parameters:
    # * +element+ - An Hpricot::Elem object.
    def self.node_to_hash(node)
      hash = {}
      
      node.each_child do |child|
        
        if child.name == 'rowset'
          key = child.attributes['name']
          value = child.children.nil? ? [] : child.children.map { |row| format_hash(row.attributes.to_hash) }
        else
          if child.children.nil?
            key, value = child.name, nil
          elsif child.children.size == 1 && child.children.first.text?
            key, value = child.name, child.children.first.raw_string
          else
            key, value = child.name, node_to_hash(child)
          end
        end
        
        hash[key] = value
      end
        
      format_hash(hash)
    end
    
    # Formats hash keys from camel case to underscore case.
    def self.format_hash(hash)
      {}.tap do |h|
        hash.each { |key, value| h[key.gsub(/(.)([A-Z])/, '\1_\2').downcase] = value }
      end
    end
    
    # Makes a HTTP GET request the EVE Online API.
    #
    # Parameters:
    # * +uri+ - A string describing the URI to send a request to.
    def self.request(uri)
      uri = URI.parse('http://api.eve-online.com' + uri + '?userID=2638016&apiKey=2dDTeLIAufRKzzjn2xKgZXPhv21NWYFyFXoC5dxFFq9vEnSMwPv76HoeEpiBsxy7&characterID=890734292')
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 3
      http.read_timeout = 20
      
      request = Net::HTTP::Get.new(uri.path + '?' + uri.query)
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