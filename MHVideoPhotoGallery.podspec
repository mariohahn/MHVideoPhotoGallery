Pod::Spec.new do |s|
  s.name         = 'MHVideoPhotoGallery'
  s.version      = '2.6.0'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/ctarda/MHVideoPhotoGallery'
  s.author = {
    'Mario Hahn' => 'mario_hahn@me.com'
  }
  s.summary      = 'Gallery for iOS 7 Devices.'
  s.platform     =  :ios
  s.source = {
    :git => 'https://github.com/ctarda/MHVideoPhotoGallery.git',
    :tag => 'v2.6.0'
  }

  s.dependency 'SDWebImage'
  s.dependency 'TTTAttributedLabel'
  s.dependency 'Masonry'

  s.frameworks = 'MessageUI','Social', 'ImageIO', 'QuartzCore', 'Accelerate','CoreMedia', 'AVFoundation','MediaPlayer'

  s.resources = "MHVideoPhotoGallery/MMHVideoPhotoGallery/**/*.{png,bundle}"
  s.public_header_files = "MHVideoPhotoGallery/MMHVideoPhotoGallery/**/*.h"
  s.source_files = ['MHVideoPhotoGallery/MMHVideoPhotoGallery/**/*.{h,m}']
  s.ios.deployment_target = '7.0'
  s.requires_arc = true
end