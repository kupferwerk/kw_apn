begin
  require 'json'
rescue
  puts "Warning: you need the json gem for apns to work!"
end

class Hash
  MAX_PAYLOAD_LEN = 256

  # Converts hash into JSON String.
  # When payload is too long but can be chopped, tries to cut self.[:aps][:alert].
  # If payload still don't fit Apple's restrictions, returns nil
  #
  # @return [String, nil] the object converted into JSON or nil.
  def to_apn_payload
    # Payload too long
    if (to_json.length > MAX_PAYLOAD_LEN)
      alert = self[:aps][:alert]
      self[:aps][:alert] = ''
      # can be chopped?
      if (to_json.length > MAX_PAYLOAD_LEN)
        return nil
      else # inefficient way, but payload may be full of unicode-escaped chars, so...
        self[:aps][:alert] = alert
        while (self.to_json.length > MAX_PAYLOAD_LEN)
          self[:aps][:alert].chop!
        end
      end
    end
    to_json
  end

  # Invokes {Hash#to_payload} and returns it's length
  # @return [Fixnum, nil] length of object converted into JSON or nil.
  def apn_payload_length
    p = to_apn_payload
    p ? p.length : nil
  end

end

module KwAPN

  class Notification

    attr_accessor :identifier, :token, :token_original
    def initialize(token_original, token, payload, timestamp = 0)
      @token_original, @token, @payload, @timestamp = token_original, token, payload, timestamp
    end

    # Creates new notification with given token and payload
    # @param [String, Fixnum] token APNs token of device to notify
    # @param [Hash, String] payload attached payload
    def Notification.create(token, payload, timestamp=0)
      Notification.new(token, token.kind_of?(String) ? token.delete(' ') : token.to_s(16) , payload.kind_of?(Hash) ? payload.to_apn_payload : payload, timestamp)
    end

    # Converts to binary string wich can be writen directly into socket
    # @return [String] binary string representation  
    def to_s
      [1, @identifier, @timestamp, 32, @token, @payload.length, @payload].pack("CNNnH*na*")
    end

  end

end
