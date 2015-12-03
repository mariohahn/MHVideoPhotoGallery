
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

#ifdef COCOAPODS
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <SDWebImage/SDWebImageDecoder.h>
#import <SDWebImage/SDImageCache.h>
#else
#import "TTTAttributedLabel.h"
#import "SDWebImageDecoder.h"
#import "SDImageCache.h"
#endif

#define MHISIPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define kMHGalleryBundleName @"MHGallery"
#define kMHGalleryBundleExtension @"bundle"
#define MHGalleryOSVersion [UIDevice.currentDevice.systemVersion floatValue]

extern void MHGalleryCustomLocalizationBlock(NSString *(^customLocalizationBlock)(NSString *stringToLocalize));
extern void MHGalleryCustomImageBlock(UIImage *(^customImageBlock)(NSString *imageToChangeName));

extern NSNumberFormatter *MHNumberFormatterVideo(void);

extern NSBundle *MHGalleryBundle(void);

extern NSString *MHGalleryLocalizedString(NSString *localizeString);

extern NSDictionary *MHDictionaryForQueryString(NSString *string);

extern UIImage *MHImageFromView(UIView *view);
extern UIImage *MHTemplateImage(NSString *imageName);
extern UIImage *MHDefaultImageForFrame(CGRect frame);
extern UIImage  *MHGalleryImage(NSString *imageName);

extern UIView  *MHStatusBar(void);
extern BOOL     MHShouldShowStatusBar(void);

extern NSString *const MHYoutubeChannel;
extern NSString *const MHGalleryViewModeShare;
extern NSString *const MHVimeoVideoBaseURL;
extern NSString *const MHVimeoThumbBaseURL;
extern NSString *const MHYoutubeInfoBaseURL;
extern NSString *const MHYoutubePlayBaseURL;
extern NSString *const MHYoutubeBaseURL;
extern NSString *const MHVimeoBaseURL;
extern NSString *const MHAssetLibrary;
extern NSString *const MHGalleryDurationData;

@interface SDImageCache (MHPrivateMethods)
- (NSString *)defaultCachePathForKey:(NSString *)key;
- (NSString *)cachedFileNameForKey:(NSString *)key;
@end


@interface TTTAttributedLabel (MHPrivateMethods)
@property (readwrite, nonatomic, strong) TTTAttributedLabelLink *activeLink;
@end

