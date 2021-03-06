require 'addressable/template'
require 'rest-client'
require 'json'

module Foaas
  class Client

  	URL = Addressable::Template.new("http://foaas.com/{method}{/name}/{from}{/other}")

    METHODS_ONE_PARAM = [:anyway, :awesome, :because, :bucket, :bye, :cool, :diabetes, :everyone, :everything, :family, :fascinating, :flying, :give, :horse, :life, :looking, :me, :mornin, :pink, :retard, :sake, :thanks, :this, :tucker, :thumbs,:what, :zayn, :zero]
    METHODS_TWO_PARAMS = [:back, :bday, :bm, :bus, :caniuse, :chainsaw, :dalton, :donut, :greed, :gfy, :keep, :keepcalm, :king, :linus, :look, :madison, :no, :nugget, :off, :outside, :pulp, :shakespeare, :shutup, :single,:think, :you, :xmas, :yoda]
    METHODS_THREE_PARAMS = [:ballmer, :dosomething, :field]

    def method_missing(sym, *args, &block)
        kwargs = {}
        kwargs = args[-1] if args[-1].class == Hash
        if METHODS_TWO_PARAMS.include? sym
          make_request(URL.expand(method: sym, name: args[0], from: args[1]), type=kwargs[:type], i18n=kwargs[:i18n], shoutcloud=kwargs[:shoutcloud])
        elsif  METHODS_ONE_PARAM.include? sym
          make_request(URL.expand(method: sym, from: args[0]), type=kwargs[:type], i18n=kwargs[:i18n], shoutcloud=kwargs[:shoutcloud])
        elsif METHODS_THREE_PARAMS.include? sym
          make_request(URL.expand(method: sym, name: args[0], from: args[1], other: args[2]), type=kwargs[:type], i18n=kwargs[:i18n], shoutcloud=kwargs[:shoutcloud])
        elsif sym == :thing
          make_request(URL.expand(method: args[0], from: args[1]), type=kwargs[:type], i18n=kwargs[:i18n], shoutcloud=kwargs[:shoutcloud])
        else
          super(sym, *args, &block)
        end
    end

    def operations
      make_request(URL.expand(method: :operations), nil)
    end

    def respond_to?(sym, include_private = false)
      METHODS_ONE_PARAM.include?(sym) or METHODS_TWO_PARAMS.include?(sym) or sym == :thing or super(sym, include_private)
    end

    def version(opts={})
      make_request(URL.expand(method: :version), opts[:type])
    end

  	private

  	def make_request(url, type=:json, i18n=nil, shoutcloud=false)
      query_params = {}
      url = url.to_s
      accept_type = case type
        when nil
          :json
        when :text
          'text/plain'
        when :jsonp
          query_params['callback'] = 'fuck' 
          :json
        else
          type
      end

      if i18n
        query_params['i18n'] = i18n
      end

      if shoutcloud
        query_params['shoutcloud'] = nil
      end

      if not query_params.empty?
        url += '?' + query_params.map do |k,v|
          if v
            "#{k}=#{v}"
          else
            k.to_s
          end
        end.join('&')
      end

      response = RestClient.get url, { accept: accept_type }
      response = JSON.parse(response) if type.nil?
      response
  	end
  	
  end
end
