Pod::Spec.new do |s|
  s.name             = 'SecureDefaults'
  s.version          = '1.0.2'
  s.summary          = 'SecureDefaults is a wrapper over UserDefaults with an extra AES256 encryption layer (key size has 256-bit length)'
  s.homepage         = 'https://github.com/vpeschenkov/SecureDefaults'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Victor Peschenkov' => 'v.peschenkov@gmail.com' }
  s.source           = { :git => 'https://github.com/vpeschenkov/SecureDefaults.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.social_media_url = 'https://twitter.com/vpeschenkov'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.source_files = 'Sources/SecureDefaults/**/*'
end
