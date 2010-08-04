subversion = ENV['PATCH_VERSION'] || '00'
version = "0.1.#{Time.now.strftime("%y%j")}.#{subversion}"

File.open(File.join(File.dirname(__FILE__), 'VERSION'), 'w') do |f|
  f.write(version)
end

Gem::Specification.new do |s|
  s.name = 'kw_apn'
  s.version = version
  s.authors = ['Jonathan Cichon']
  s.email = 'cichon@kupferwerk.com'
  s.homepage = 'http://kupferwerk.com'
  s.summary = 'APN Lib by Kupferwerk'
  s.description = 'Apple Push Notification Library by Kupferwerk'
  s.has_rdoc = true
  
  s.require_path = 'lib'
  s.files = Dir['lib/**/*'] + Dir['*.gemspec'] + ['Rakefile', 'README.rdoc', 'VERSION']
end