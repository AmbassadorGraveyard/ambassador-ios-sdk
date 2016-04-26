Pod::Spec.new do |s|
   s.name = "Ambassador"
   s.platform = :ios
   s.version = "1.0.3"
   s.summary = "Ambassador Referral Marketing SDK for iOS"
   s.homepage = "https://www.getambassador.com"
   s.license = { :type => 'MIT' }
   s.author = { "Jake Dunahee" => "jake@getambassdor.com" }
   s.source = { :git => "https://github.com/GetAmbassador/ambassador-ios-sdk.git", :branch => '116791581_add_sdk_to_cocoapods' }
   #s.frameworks = 'ZipZap'
   s.requires_arc = true
   s.source_files = "Ambassador/Ambassador/*/*/*"
end
