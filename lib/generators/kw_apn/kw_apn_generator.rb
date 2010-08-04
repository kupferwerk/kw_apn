require 'rails/generators'

class KwApnGenerator < Rails::Generators::Base

  def install_kw_apn
    source_paths << File.join(File.dirname(__FILE__), 'templates')
    
    copy_file "config/kw_apn.yml"
    directory "config/cert"
    directory "log"
    copy_file "log/kw_apn.log"
    
    gem 'kw_apn'
  end

    

end