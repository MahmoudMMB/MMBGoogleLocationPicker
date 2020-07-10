Pod::Spec.new do |s|
  s.name             = "MMBGoogleLocationPicker"
  s.version          = "0.0.1"
  s.summary          = "A ready for use and fully customizable location picker for your app."

  s.homepage         = "https://github.com/MahmoudMMB/MMBGoogleLocationPicker"
  s.screenshots      = "https://raw.githubusercontent.com/MahmoudMMB/MMBGoogleLocationPicker/master/Screenshots/locationpicker.gif"
  s.license          = 'MahmoudMMB'
  s.author           = { 'MahmoudMMB' => 'mmbelbeisi@gmail.com' }
  s.source           = { :git => "https://github.com/MahmoudMMB/MMBGoogleLocationPicker.git", :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.swift_version = '4.2'
  s.source_files = 'LocationPicker/*.{h,m,swift}'
  s.resource_bundles  = {
    'MMBGoogleLocationPicker' => [
      'LocationPicker/Resources/*.{lproj,storyboard}/*.{xib,strings}'
    ],
    'Resources' => [
      'LocationPicker/Resources/*.lproj'
    ]
  }

  s.exclude_files = "LocationPicker/*.plist"
end
