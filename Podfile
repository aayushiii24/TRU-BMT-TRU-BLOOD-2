# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'TRU-BMT' do
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
# use_frameworks!
# Pods for TRU-Pain
pod 'MagicalRecord/Shorthand'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'GoogleSignIn'
pod 'Firebase/Messaging'
pod 'FirebaseDatabase'
pod 'FirebaseStorage'
pod 'Firebase/Firestore'

# pod 'Parse'
end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['SWIFT_VERSION'] = '3.0'
end
end
end
