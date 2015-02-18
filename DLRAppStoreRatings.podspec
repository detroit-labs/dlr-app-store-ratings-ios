Pod::Spec.new do |s|
  s.name             = "DLRAppStoreRatings"
  s.version          = "1.0.0"
  s.summary          = "Engine to track app events and determine when to show an app ratings prompt."
  s.homepage         = "https://github.com/detroit-labs/dlr-app-store-ratings-ios"
  s.license          = 'COMMERCIAL'
  s.authors          = { "Chris Trevarthen" => "ctrevarthen@detroitlabs.com",
                         "Nathan Walczak" => "nate.walczak@detroitlabs.com" }
  s.source           = { :git => "https://github.com/detroit-labs/dlr-app-store-ratings-ios.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/detroitlabs'

  s.platform     = :ios
  s.requires_arc = true

  s.source_files = 'DLRAppStoreRatings/source/**/*'

  s.public_header_files = 'DLRAppStoreRatings/source/**/*.h'

  s.dependency 'DLRUIKit', '~> 1.2.0'
end
