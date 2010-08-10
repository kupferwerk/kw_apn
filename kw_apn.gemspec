version =  File.read('VERSION')

File.open(File.join(File.dirname(__FILE__), 'VERSION'), 'w') do |f|
  f.write(version)
end

Gem::Specification.new do |s|
  s.name = 'kw_apn'
  s.version = version
  s.authors = ['Jonathan Cichon', 'Kupferwerk GmbH']
  s.email = 'cichon@kupferwerk.com'
  s.homepage = 'http://github.com/kupferwerk/kw_apn'
  s.summary = 'APN Lib by Kupferwerk'
  s.description = 'Apple Push Notification Library by Kupferwerk'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc']
  s.require_path = 'lib'
  s.files = Dir['lib/**/*'] + Dir['*.gemspec'] + ['Rakefile', 'README.rdoc', 'VERSION']
end