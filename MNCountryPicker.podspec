Pod::Spec.new do |s|
  s.name         = 'MNCountryPicker'
  s.version      = '1.3.0'
  s.summary      = 'MNCountryPicker is a swift country picker controller. Provides country name, ISO 3166 country codes, and calling codes'
  s.homepage     = 'https://github.com/meetnow/MNCountryPicker'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Patrick Schneider' => 'https://github.com/meetnow/MNCountryPicker' }

  s.platform     = :ios
  s.ios.deployment_target = '8.0'

  s.source       = { :git => 'https://github.com/meetnow/MNCountryPicker.git', :tag => '1.1.0' }
  s.source_files = 'Pod/Classes/*.swift'
  s.resource_bundles = {
    'MNCountryPicker' => ['Pod/Assets/close_icon*.png', 'Pod/Assets/CallingCodes.plist']
  }
  s.requires_arc = true
end
