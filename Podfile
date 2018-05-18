# Uncomment the next line to define a global platform for your project
platform :ios, '11.3'
target 'WeNewsAPP' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WeNewsAPP
  pod 'Moya'
  pod 'ObjectMapper'
  pod 'PageMenu'
  pod 'IQKeyboardManagerSwift'
  pod 'LeoDanmakuKit'
  pod 'LLSwitch'
  pod 'WZLBadge'
#  pod 'Tabman'
  pod 'MJRefresh'
  pod 'JHSpinner'
  pod 'NotificationBannerSwift'
  pod 'Cosmos'
  pod 'Cards'
#  pod 'Material'
  pod 'YYCache'

post_install do |installer| installer.pods_project.build_configurations.each do |config|
config.build_settings.delete('CODE_SIGNING_ALLOWED')
config.build_settings.delete('CODE_SIGNING_REQUIRED') end end
#  target 'WeNewsAPPTests' do
#      inherit! :search_paths
#      # Pods for testing
#  end
#
#  target 'WeNewsAPPUITests' do
#      inherit! :search_paths
#      # Pods for testing
#  end

end
