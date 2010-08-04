module KwAPN
  class FeedbackReader < Connection
    
    attr_accessor :host, :port
    def initialize(host=nil, port=nil)
      @host = host || KwAPN::Config.options[:feedback_host]
      @port = port || KwAPN::Config.options[:feedback_port]
    end
    
    def read
      records ||= []
      begin
        @ssl = connect(@host, @port, KwAPN::Config.options)
        while record = @ssl.read(38)
          feedback = record.strip.unpack('NnH*')
          records << feedback[2].scan(/.{0,8}/).join(' ').strip
        end
      rescue => e
        puts "Error reading feedback channel: #{e.message}"
      ensure
        @ssl.close
      end
      return records
    end
  end
end