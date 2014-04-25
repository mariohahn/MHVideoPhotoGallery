
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImageView+MHGallery.h"
#import "MHTransitionDismissMHGallery.h"
#import "MHTransitionPresentMHGallery.h"
#import "MHPresenterImageView.h"
#import "MHCustomization.h"
#import "MHGalleryItem.h"
#import "MHGallerySharedManager.h"
#import "MHGalleryController.h"
#import "MHOverviewController.h"
#import "MHTransitionShowOverView.h"
#import "MHGalleryImageViewerViewController.h"

#import "SDWebImageDecoder.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

#define MHISIPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define kMHGalleryBundleName @"MHGallery.bundle"

extern void MHGalleryCustomLocalizationBlock(NSString *(^customLocalizationBlock)(NSString *stringToLocalize));
extern void MHGalleryCustomImageBlock(UIImage *(^customImageBlock)(NSString *imageToChangeName));

extern NSNumberFormatter *MHNumberFormatterVideo(void);
extern NSBundle *MHGalleryBundle(void);
extern NSString *MHGalleryLocalizedString(NSString *localizeString);
extern UIImage  *MHGalleryImage(NSString *imageName);
extern NSDictionary *MHDictionaryForQueryString(NSString *string);
extern UIImage *MHImageFromView(UIView *view);

extern NSString *const MHYoutubeChannel;
extern NSString *const MHGalleryViewModeShare;
extern NSString *const MHVimeoVideoBaseURL;
extern NSString *const MHVimeoThumbBaseURL;
extern NSString *const MHYoutubeInfoBaseURL;
extern NSString *const MHYoutubePlayBaseURL;
extern NSString *const MHYoutubeBaseURL;
extern NSString *const MHVimeoBaseURL;

@interface SDImageCache (MHPrivateMethods)
- (NSString *)defaultCachePathForKey:(NSString *)key;
- (NSString *)cachedFileNameForKey:(NSString *)key;
@end

