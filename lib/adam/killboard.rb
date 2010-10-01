require 'adam/killboard/feed_error'

require 'date'
require 'net/http'
require 'uri'
require 'cgi'
require 'hpricot'

module Adam
  
  class Killboard
    attr_reader :uri, :feed_uri
    
    def initialize(options = {})      
      @uri, @feed_uri = options[:uri], options[:feed_uri]
    end
    
    # Parses an EDK-compatible feed and returns an array of killmail strings.
    #
    # +options+ is a hash with these keys:
    # * +week+ - An integer determining which week to import. Defaults to current week.
    # * +year+ - An integer determining which year to import the week from. Defaults to current year.
    def killmails(options = {})
      options = { :week => Date.today.cweek, :year => Date.today.year }.merge!(options)
      
      uri = URI.parse(@feed_uri)
              
      query_string = { 'week' => options[:week], 'year' => options[:year], 'nocache' => Time.now.to_i }.map{ |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
      
      response = nil
      connection = Net::HTTP.new(uri.host, uri.port)
      connection.start do |http|
        tries = 0
        begin
          response = http.get(uri.path + '?' + uri.query + '&'  + query_string)
        rescue Timeout::Error
          tries += 1
          sleep 10
          retry if tries < 3
        end
      end
      
      xml = Hpricot.XML(response.body)
      
      raise FeedError.new(response.body), "Feed malformed" unless xml.at('/rss')
      
      killmails = xml.search("//item/description").collect { |element| element.inner_text }
    end
    
  end
  
end
