module KwAPN
  require 'erb'
  class Config
    class << self
      def options
        @@options ||= nil
        unless @@options
          p_root = if defined? Rails
            Rails.root
          elsif defined? RACK_ROOT
            RACK_ROOT
          else
            puts "Warning (KwAPN): You need to specifiy either Rails.root or RACK_ROOT for apns to work!"
            nil
          end
          
          p_env = if defined? Rails
            Rails.env
          elsif defined? RACK_ENV
            RACK_ENV
          else
            puts "Warning (KwAPN): You need to specifiy either Rails.env or RACK_ENV for apns to work!"
            nil
          end
          
          @@options = begin
              raw_config = File.read(p_root.join("config", "kw_apn.yml"))
              parsed_config = ERB.new(raw_config).result
              YAML.load(parsed_config)[p_env].symbolize_keys
          rescue => e
              puts "Warning (KwAPN): Could not parse config file: #{e.message}"
              {}
          end
          @@options[:root] = p_root
        end
        return @@options
      end
    end
  end
end