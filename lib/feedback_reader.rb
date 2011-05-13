module KwAPN
  class FeedbackReader < Connection
    
    attr_accessor :host, :port
    def initialize(app_id = nil)
      @host = KwAPN::Config.option(:feedback_host, app_id)
      @port = KwAPN::Config.option(:feedback_port, app_id)  || 2196
      @app_id = app_id
    end
    
    def read
      records ||= []
      begin
        @ssl = connect(@host, @port, @app_id)
        while record = @ssl.read(38)
          feedback = record.strip.unpack('NnH*')
          records << feedback[2].scan(/.{0,8}/).join(' ').strip
        end
      rescue => e
        puts "Error reading feedback channel: #{e.message}"
      ensure
        @ssl.close if @ssl
      end
      return records
    end
  end
end