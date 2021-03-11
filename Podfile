# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'
  target 'NotificationService' do
 
  use_frameworks!
  
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  
end
target 'CouplesDelight' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CouplesDelight
  # add the Firebase pod for Google Analytics
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods
  pod 'SwiftyRSA'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'
  pod 'SDWebImageSwiftUI'
  pod 'Alamofire', '~> 5.2'
  pod 'lottie-ios'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/Functions'
  pod 'Firebase/Crashlytics'
  pod 'ExyteGrid'
    
 post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new('9.0') > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end
	

end
