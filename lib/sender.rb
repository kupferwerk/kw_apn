module KwAPN

  # maybe somebody knows why but Apple seems to have dificulties handling identifiers between 9 and ~ 20
  # if there is a bug on our side feel free to fix it, but for now it seems to work with the offset workaround
  ID_OFFSET = 333
  class Sender < Connection
    attr_accessor :host, :port, :count, :fail_count, :work_thread, :watch_thread, :failed_index_array, :session_id, :last_error_index

    # Creates new {Sender} object with given host and port
    def initialize(session_id, host=nil, port=nil)
      @session_id = session_id
      @host = host || KwAPN::Config.options[:push_host] || 'gateway.sandbox.push.apple.com'
      @port = port || KwAPN::Config.options[:push_port] || 2195
      @count = 0
      @fail_count = 0
      @failed_index_array = []
      self
    end
    
    def push_batch(notifications=[])
      begin
        if @ssl != nil
          return [:nok, 'Start a new Connection for every batch you want to perform'] 
        end
        @count = notifications.length
        start_threads(notifications)
        return [:ok, @failed_index_array.collect{|a| notifications[a].token}]
      rescue => e
        failed
        self.class.log("(#{session_id}) Exception: #{e.message}")
        return [:nok, "Exception: #{e.message}"]
      end
    end
    
    def close_connection
      @ssl.close if @ssl
      @ssl = nil
    end
    
private
    
    def start_threads(notifications, index=0)
      @last_error_index = nil
      @ssl = connect(@host, @port, KwAPN::Config.options)
      if @ssl
        @watch_thread = Thread.new do 
          perform_watch()
        end
        
        @work_thread = Thread.new do 
          perform_batch(notifications, index)
        end
        
        @work_thread.join
        
        if @failed_index_array.last and index <= @failed_index_array.last and @failed_index_array.last < @count - 1 and @ssl.nil?
          # wait for apple to respond errors
#          sleep(1)
          start_threads(notifications, @failed_index_array.last + 1)
        end
      else
        failed
      end      
    end

    def perform_batch(notifications, index=0)
      begin
        notifications[index..-1].each_with_index do |n, i|
          n.identifier = i + index + ID_OFFSET
          bytes = @ssl.write(n.to_s)
          if bytes <= 0
            raise "write returned #{bytes} bytes"
          end
        end
        # wait for apple to respond errors
        sleep(1)
      rescue => e
        if @last_error_index.nil?
          # stop watchthread as the connection should be allready down
          @watch_thread.exit
          self.class.log("(#{session_id}) Exception at index #{i+index}: #{e.message}")
          @failed_index_array << (i+index)
          failed
        else
          # should be interrupted by watchthread, do nothing wait for restart
        end
      end
    end
    
    def perform_watch
      ret = @ssl.read
      err = ret.strip.unpack('CCN')
      if err[1] != 0 and err[2]
        @last_error_index = (err[2] - ID_OFFSET)
        @failed_index_array << @last_error_index
        failed
        @work_thread.exit
      else
        perform_watch
      end
    end

    def failed
      @fail_count += 1
      close_connection
    end
    
    def error_msg(status)
      case status
      when 1
        "Processing error"
      when 2
        "Missing device token"
      when 3
        "Missing topic"
      when 4
        "Missing payload"
      when 5
        "Invalid token size"
      when 6
        "Invalid topic size"
      when 7
        "Invalid payload size"
      when 8
        "Invalid token"
      when 255
        "unknown"
      end
    end
    
    class << self
      # convenient way of connecting with apple and pushing the notifications
      # @param [Array] notifications - An Array of Objects of Type KwAPN::Notification
      # @param [String] session_id - A Identifier for Login purpose
      #
      # @returns [Symbol, Array/String] if no Problems occured :ok and an Array of Tokens failed to push is returned. The Caller should take care of those invalid Tokens.
      def push(notifications, session_id=nil)
        s = self.new(session_id)
        startdate = Time.now
        status, ret = s.push_batch(notifications)
        log("(#{session_id}) #{startdate.to_s} SENT APN #{s.count - s.fail_count}/#{s.count} in #{Time.now.to_i - startdate.to_i} seconds")
        s.close_connection
        return [status, ret]
      end
    end
  end
end

