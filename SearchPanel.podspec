#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "SearchPanel"
  s.version          = "1.0"
  s.summary          = "SearchPanel is a Maps-like search panel"
  s.description      = <<-DESC
                        SearchPanel is a Maps-like search panel
						Check the README for more informations
                       DESC
  s.homepage         = "https://github.com/MonkeyDMat/SearchPanel"

  s.license          = 'BSD'
  s.author           = { "Mathieu Lecoupeur" => "mathieulecoupeur@gmail.com" }
  s.requires_arc = true
  s.ios.deployment_target     = '9.0'
  s.platforms = { :ios => "9.0" }
  
  s.source           = { :git => 'https://github.com/MonkeyDMat/SearchPanel.git',
                	 	 :tag => "#{s.version}"}
  s.source_files     = [
    'SearchPanel/src/**/*.swift'
  ]
  s.resource_bundle		= { 'SearchPanel' => ['SearchPanel/src/**/*.storyboard', 'SearchPanel/Assets.xcassets/**/*.imageset']}
  s.resources		= ['SearchPanel/Assets.xcassets/**/*.imageset']
end
