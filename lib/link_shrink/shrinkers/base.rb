require 'uri'

module LinkShrink
  module Shrinkers
    # @author Jonah Ruiz <jonah@pixelhipsters.com>
    #   Base class for implementing other URL APIs
    #
    # @abstract Subclass and override methods as needed
    # @example Implement a Shrinker class
    #   class Shorty < Base
    #
    #    def base_url
    #      'http://shorty.com/api/2.0/shorten'
    #    end
    #
    #    def api_query_parameter
    #      "?url=#{url}"
    #    end
    #
    #    def api_url
    #      base_url.concat api_query_parameter
    #    end
    #  end
    class Base

      # @!attribute url
      # @return [String] long url to shrink
      attr_reader :url

      # Callback method to define a sub_klass method for reference
      # @return [String] inherited class name
      def self.inherited(sub_klass)
        sub_klass.class_eval do
          define_method 'sub_klass' do
            @sub_klass = "#{sub_klass.name}"[/::(\w+)::(\w+)/, 2]
          end
        end
      end

      # @overload base_url
      #   URL base for API requests
      # @raise [String] unless implemented on inheriting class
      # @return [String] api base URL
      def base_url
        fail "#{__method__} not implemented"
      end

      # @overload api_query_parameter
      #   URL query parameters
      # @raise [String] unless implemented on inheriting class
      # @return [String] query parameters to be used in request
      def api_query_parameter
        fail "#{__method__} not implemented"
      end

      # Parameters to be used in API request
      # @param params [Hash] parameters to be used
      # @return [NilClass] nil if parameters are empty
      def body_parameters(params = {})
        nil if params.empty?
      end

      # Complete URL with query parameters
      def api_url
        api_key? ? base_url.concat(api_query_parameter) : base_url
      end

      # Predicate method for checking if the API key exists
      # @return [TrueClass, FalseClass]
      def api_key?
        ENV.has_key?("#{sub_klass.upcase}_URL_KEY")
      end

      # Returns API Key
      # @return [String] API key or nil
      def api_key
        api_key? ? ENV["#{sub_klass.upcase}_URL_KEY"] : nil
      end

      # Encodes URL
      # @param new_url [String] url to be parsed
      # @return [String] parsed URL
      def sanitize_url(new_url)
        URI.encode(
          !(new_url =~ /^(http?:\/\/)?/) ? "http://#{new_url}" : new_url
        )
      end

      # @overload http_method
      #   Returns HTTP method to be used in request
      #     override +:get+ with +:post+
      # @return [Symbol] http method
      def http_method
        :get
      end

      # @overload content_type
      #   Returns Content-Type to be used in Request headers
      # @return [String] content-type
      def content_type
        'application/json'
      end

      # Sets URL to be used in request
      # @see #sanitize_url
      # @param new_url [String] url to be parsed
      # @return [String] parsed url
      def url=(new_url)
        @url = sanitize_url(new_url)
      end

      # Method for generating QR codes or charts
      # @param new_url [String] url to be processed
      # @param image_size [Hash<symbol>] image size target
      # @return [String] chart or qr code url
      def generate_chart_url(new_url, image_size = {})
        fail "#{__method__} not implemented"
      end

      # Handles DSL definition of response structure to be parsed (JSON)
      # @!group ShrinkerDSL
      class << self
        attr_accessor :collection_key, :url_key, :error_key

        # Helper method that yields into the other response structure methods
        def response_options(&block)
          yield
        end

        # Defines collection_key in response
        # @param new_collection [String] collection_key
        def collection(new_collection)
          self.collection_key = new_collection
        end

        # Defines url_key in response
        # @param short_url_key [String] url_key
        def short_url(short_url_key)
          self.url_key = short_url_key
        end

        # Defines error_key in response
        # @param new_error_key [String] error_key
        def error(new_error_key = 'error')
          self.error_key = new_error_key
        end
      end
      # @!endgroup

    end
  end
end
