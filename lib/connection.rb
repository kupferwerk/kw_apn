module KwAPN
  
  require 'socket'
  require 'openssl'
  
  class Connection
    
    def connect(host, port, opts)
      ctx = OpenSSL::SSL::SSLContext.new()
      ctx.cert = OpenSSL::X509::Certificate.new(File::read(opts[:cert_file]))
      ctx.key  = OpenSSL::PKey::RSA.new(File::read(opts[:cert_file]))

      s = TCPSocket.new(host, port)
      ssl = OpenSSL::SSL::SSLSocket.new(s, ctx)
      ssl.connect # start SSL session
      ssl.sync_close = true # close underlying socket on SSLSocket#close
      ssl
    end
    
    class << self
      def log(s)
        File.open(KwAPN::Config.option(:root).join("log", "kw_apn.log"), File::WRONLY|File::APPEND|File::CREAT, 0666) do |f|
          f.write("#{s}\n")
        end
      end
    end
    
  end
  
end