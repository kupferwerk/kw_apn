module KwAPN
  require 'erb'
  class Config    
    class << self
      attr_accessor :default_push_host
      attr_accessor :default_feedback_host
      
      # calculates the project environment (uses Rails or RACK_ENV if available)
      def env
        @p_env ||= if defined? Rails
          Rails.env
        elsif defined? RACK_ENV
          RACK_ENV
        else
          puts "Warning (KwAPN): You need to specifiy either Rails.env or RACK_ENV for apns to work!"
          'development'
        end
      end

      # calculates the project root (uses Rails or RACK_ROOT if available)
      def root
        p_root ||= if defined? Rails
          Rails.root
        elsif defined? RACK_ROOT
          RACK_ROOT
        else
          puts "Warning (KwAPN): You need to specifiy either Rails.root or RACK_ROOT for apns to work!"
          nil
        end
      end
      
      # loads the options from '/config/kw_apn.yml'
      def load_options
        @options = begin
          raw_config = File.read(root.join("config", "kw_apn.yml"))
          parsed_config = ERB.new(raw_config).result
          YAML.load(parsed_config)[env].symbolize_keys
        rescue => e
          puts "Warning (KwAPN): Could not parse config file: #{e.message}"
          {}
        end
        @options[:root] ||= root
        @options[:push_host] ||= default_push_host
        @options[:feedback_host] ||= default_feedback_host
        true
      end
      
      # returns or loads the current options
      def option(opt, app_id = nil)
        @options || load_options
        if app_id && @options[app_id] && @options[app_id][opt]
          @options[app_id][opt]
        else
          @options[opt]
        end
      end
    end

      # set some default options based on the envrionment
      if self.env == 'production'
        self.default_push_host = 'gateway.push.apple.com'
        self.default_feedback_host = 'feedback.push.apple.com'
      else
        self.default_push_host = 'gateway.sandbox.push.apple.com'
        self.default_feedback_host = 'feedback.sandbox.push.apple.com'
      end
      
  end
end