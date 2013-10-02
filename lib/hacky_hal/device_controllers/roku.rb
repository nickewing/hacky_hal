require "net/http"
require "uri"
require "cgi"
require "rexml/document"
require_relative "base"

# Docs: http://sdkdocs.roku.com/display/sdkdoc/External+Control+Guide

module HackyHAL
  module DeviceControllers
    class Roku < Base
      KEY_HOME = "Home"
      KEY_REVERSE = "Rev"
      KEY_FORWARD = "Fwd"
      KEY_PLAY = "Play"
      KEY_SELECT = "Select"
      KEY_LEFT = "Left"
      KEY_RIGHT = "Right"
      KEY_DOWN = "Down"
      KEY_UP = "Up"
      KEY_BACK = "Back"
      KEY_INSTANT_REPLAY = "InstantReplay"
      KEY_INFO = "Info"
      KEY_BACKSPACE = "Backspace"
      KEY_SEARCH = "Search"
      KEY_ENTER = "Enter"

      NAMED_KEYS = Set.new([
        KEY_HOME, KEY_REVERSE, KEY_FORWARD, KEY_PLAY,
        KEY_SELECT, KEY_LEFT, KEY_RIGHT, KEY_DOWN,
        KEY_UP, KEY_BACK, KEY_INSTANT_REPLAY, KEY_INFO,
        KEY_BACKSPACE, KEY_SEARCH, KEY_ENTER
      ])

      def initialize(options)
        super(options)
        ensure_option(:device_resolver)
        @host_uri = options[:device_resolver].uri

        log("Host found at: #{@host_uri.to_s}", :debug)
      end

      def channel_list
        response = get_request("/query/apps")
        response_document = REXML::Document.new(response.body)
        
        response_document.elements.to_a("apps/app").map do |app|
          id = app.attributes["id"]
          version = app.attributes["version"]
          name = app.text

          {id: id, version: version, name: name}
        end
      end

      def launch(channel_id, query_params = nil)
        post_request("/launch/#{channel_id}", query_params)
      end

      def icon(channel_id)
        response = get_request("/query/icon/#{channel_id}")
        {type: response["content-type"], body: response.body}
      end

      def key_down(key)
        post_request("/keydown/#{key_code(key)}")
      end

      def key_up(key)
        post_request("/keyup/#{key_code(key)}")
      end
      
      def key_press(key)
        post_request("/keypress/#{key_code(key)}")
      end

      def key_press_string(string)
        string.chars.each do |char|
          key_press(char)
        end
      end

      private

      def key_code(key)
        if NAMED_KEYS.include?(key)
          key
        else
          "Lit_#{CGI::escape(key)}"
        end
      end

      def get_request(path, query_params = nil)
        http_request(Net::HTTP::Get, path, query_params)
      end

      def post_request(path, query_params = nil)
        http_request(Net::HTTP::Post, path, query_params)
      end

      def request_uri(path, query_params)
        uri = @host_uri.dup
        uri.path = path
        uri.query = URI.encode_www_form(query_params) if query_params
        uri
      end

      def http_request(request_type, path, query_params)
        uri = request_uri(path, query_params)
        http = Net::HTTP.new(uri.host, uri.port)
        request = request_type.new(uri.request_uri)
        http.request(request)
      end
    end
  end
end
