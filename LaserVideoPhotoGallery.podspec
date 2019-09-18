Pod::Spec.new do |s|
  s.name         = 'LaserVideoPhotoGallery'
  s.version      = '3.0.3'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/LaserSrl/LaserVideoPhotoGallery'
  s.author = {
    'Laser Patrick' => 'patrick.negretto@laser-group.com'
  }
  s.summary      = 'Gallery for iOS 9 Devices.'
  s.platform     =  :ios
  s.source = {
    :git => 'https://github.com/LaserSrl/LaserVideoPhotoGallery.git',
    :tag => s.version.to_s
  }

  s.dependency 'SDWebImage', '~> 5.0'
  s.dependency 'TTTAttributedLabel', '~> 2.0'
  s.dependency 'Masonry'

  s.frameworks = 'MessageUI','Social', 'ImageIO', 'QuartzCore', 'Accelerate','CoreMedia', 'AVFoundation','MediaPlayer'

  s.resources = "MHVideoPhotoGallery/MMHVideoPhotoGallery/**/*.{png,bundle}"
  s.public_header_files = "MHVideoPhotoGallery/MMHVideoPhotoGallery/**/*.h"
  s.source_files = ['MHVideoPhotoGallery/MMHVideoPhotoGallery/**/*.{h,m}']
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
end
