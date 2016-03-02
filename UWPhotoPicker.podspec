Pod::Spec.new do |s|

  s.name         = "UWPhotoPicker"
  s.version      = "1.0.3"
  s.summary      = "A image picker like Instagram."

  s.description  = <<-DESC
                   Present Image Picker like Instagram.You can crop a image using it.
                   DESC
  s.homepage     = "http://git.uniqueway.in/six/UWAImagePicker"
  s.screenshots  = "https://raw.githubusercontent.com/wenzhaot/InstagramPhotoPicker/master/Screenshots/Screenshot01.png"
  s.license      = "MIT"
  s.author       = { "wenzhaot" => "tanwenzhao1025@gmail.com" }
  s.source       = { :git => "http://git.uniqueway.in/six/UWAImagePicker.git" }
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files  = "UWPhotoPicker/*","UWPhotoPicker/instagramFilter/*/*.{h,m}"
  s.frameworks = "Foundation", "CoreGraphics", "UIKit"
  s.resources = 'UWPhotoPicker/Resources/*','UWPhotoPicker/instagramFilter/filterIcon/*'

end
