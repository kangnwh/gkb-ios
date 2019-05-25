source 'https://github.com/CocoaPods/Specs.git'
platform :ios,'10.0'
use_frameworks!

target 'GraphicMap' do
    
end



post_install do |installer|
installer.pods_project.build_configurations.each do |config|
config.build_settings.delete('CODE_SIGNING_ALLOWED')
config.build_settings.delete('CODE_SIGNING_REQUIRED')
end
end

