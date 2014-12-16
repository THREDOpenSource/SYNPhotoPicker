#
# Be sure to run `pod lib lint SYNPhotoPicker.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SYNPhotoPicker"
  s.version          = "0.1.0"
  s.summary          = "A short description of SYNPhotoPicker."
  s.description      = <<-DESC
                       An optional longer description of SYNPhotoPicker

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/Syntertainment/SYNPhotoPicker"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Timothy Johnson" => "timj@syntertainment.com" }
  s.source           = { :git => "https://github.com/Syntertainment/SYNPhotoPicker.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'SYNPhotoPicker' => ['Pod/Assets/*.png', 'Pod/Classes/SYNPhotoPickerViewController.xib', 'Pod/Classes/SYNSearchCell.xib']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SDWebImage', '3.7.1'
end
