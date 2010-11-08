require 'uri'
require 'net/http'
require 'hpricot'
require 'adam/api/error'

module Adam
  
  module API
    
    # Queries the API method described by +path+.
    #
    # Parameters:
    # * +path+ - A string describing the method to query.
    # * +options+ - An (optional) hash with keys:
    #   * +user_id+ - An integer describing an user id (optional).
    #   * +api_key+ - A string describing an api key (optional).
    #   * +character_id + An integer describing a character id (optional).
    #   * +return_xml+ A boolean determining whether or not to return raw XML (optional).
    def self.query(path, options = {})
      return_xml = options.fetch(:return_xml, false)
      
      credentials = options.select { |key| [:user_id, :api_key, :character_id].include?(key) }
      
      unless path =~ /^.*.xml.aspx$/
        path << '.xml.aspx'
      end
      
      response = request(path, credentials)
      
      if return_xml
        parse(response) and return response
      else
        return parse(response)
      end
    end
    
    private
    
    # Parses an API response.
    #
    # Parameters:
    # * +xml+ - A string with the API response.
    def self.parse(xml)
      xml = Hpricot.XML(xml.gsub!(/\n+|\r+/, '').gsub!(/(>)\s*(<)/, '\1\2'))
      
      if error = xml.at('/eveapi/error')
        raise Error.new(error['code'].to_i, error.inner_text)
      end
      
      node_to_hash(xml.at('/eveapi/result'))
    end
    
    private
    
    # Makes a HTTP request to the EVE Online API.
    #
    # Parameters:
    # * +uri+ - A string describing the URI to send a request to.
    # * +credentials+ - An (optional) hash with keys:
    #   * +user_id+ - An integer describing an user id.
    #   * +api_key+ - A string describing an api key.
    #   * +character_id + An integer describing a character id (optional).
    def self.request(uri, credentials = {})
      uri = URI.parse('http://api.eve-online.com' + uri)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 3
      http.read_timeout = 20
      
      if credentials.empty?
        request = Net::HTTP::Get.new(uri.path)
      else
        request = Net::HTTP::Get.new(uri.path + credentials_to_query_string(credentials))
      end
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
    
    # Returns credentials (user id, api key and character id) as an URL encoded query string.
    #
    # Parameters:
    # * +credentials+ - A hash with keys:
    #   * +user_id+ - An integer describing an user id.
    #   * +api_key+ - A string describing an api key.
    #   * +character_id + An integer describing a character id (optional).
    def self.credentials_to_query_string(credentials)
      user_id       = credentials.fetch(:user_id)
      api_key       = credentials.fetch(:api_key)
      character_id  = credentials.fetch(:character_id, nil)
      
      "?userID=#{user_id}&apiKey=#{api_key}&characterID=#{character_id}"
    end
    
    # Returns an XML node's hash equivalent.
    #
    # Parameters:
    # * +element+ - An Hpricot::Elem object.
    def self.node_to_hash(node)
      hash = {}
      
      node.each_child do |child|
        
        if child.name == 'rowset'
          key, value = rowset_to_hash(child)
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
    
    # Returns an XML "rowset" element's hash equivalent.
    #
    # Parameters:
    # * +rowset+ - An Hpricot::Elem object.
    def self.rowset_to_hash(rowset)
      key = rowset.attributes['name']
      if rowset.children.nil?
        value = []
      else
        value = rowset.children.map { |row| format_hash(row.attributes.to_hash) }
      end
      return key, value
    end
    
    # Formats hash keys from camel case strings to underscore case symbols.
    def self.format_hash(hash)
      formatted_hash = {}
      hash.each do |key, value|
        formatted_hash[key.gsub(/(.)([A-Z])/, '\1_\2').downcase.to_sym] = value
      end
      formatted_hash
    end
    
  end
  
end