
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+MHGallery.h"
#import "MHTransitionDismissMHGallery.h"
#import "MHTransitionPresentMHGallery.h"
#import "MHPresenterImageView.h"
#import "MHCustomization.h"

#define MHISIPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define kMHGalleryBundleName @"MHGallery.bundle"

@class MHTransitionDismissMHGallery;
@class MHTransitionPresentMHGallery;
@class MHPresenterImageView;
@class MHOverViewController;
@class MHGalleryImageViewerViewController;

extern void MHGalleryCustomLocalizationBlock(NSString *(^customLocalizationBlock)(NSString *stringToLocalize));
extern void MHGalleryCustomImageBlock(UIImage *(^customImageBlock)(NSString *imageToChangeName));

extern NSBundle *MHGalleryBundle(void);
extern NSString *MHGalleryLocalizedString(NSString *localizeString);
extern UIImage  *MHGalleryImage(NSString *imageName);
extern NSDictionary *MHDictionaryForQueryString(NSString *string);


extern NSString *const MHYoutubeChannel;
extern NSString *const MHGalleryViewModeOverView;
extern NSString *const MHGalleryViewModeShare;
extern NSString *const MHVimeoBaseURL;
extern NSString *const MHVimeoThumbBaseURL;
extern NSString *const MHYoutubeInfoBaseURL;
extern NSString *const MHYoutubePlayBaseURL;



typedef NS_ENUM(NSUInteger, MHGalleryPresentionStyle) {
    MHGalleryPresentionStyleOverView,
    MHGalleryPresentionStyleImageViewer
};

typedef NS_ENUM(NSUInteger, MHAssetImageType) {
    MHAssetImageTypeFull,
    MHAssetImageTypeThumb
};

typedef NS_ENUM(NSUInteger, MHWebPointForThumb) {
    MHWebPointForThumbStart, // Default
    MHWebPointForThumbMiddle, // videoDuration/2
    MHWebPointForThumbEnd //videoDuration
};

typedef NS_ENUM(NSUInteger, MHGalleryType) {
    MHGalleryTypeImage,
    MHGalleryTypeVideo
};

typedef NS_ENUM(NSUInteger, MHYoutubeVideoQuality) {
    MHYoutubeVideoQualityHD720, //Default
    MHYoutubeVideoQualityMedium,
    MHYoutubeVideoQualitySmall
};

typedef NS_ENUM(NSUInteger, MHVimeoVideoQuality) {
    MHVimeoVideoQualityHD, //Default
    MHVimeoVideoQualityMobile,
    MHVimeoVideoQualitySD
};

typedef NS_ENUM(NSUInteger, MHVimeoThumbQuality) {
    MHVimeoThumbQualityLarge, //Default
    MHVimeoThumbQualityMedium,
    MHVimeoThumbQualitySmall
};

typedef NS_ENUM(NSUInteger, MHWebThumbQuality) {
    MHWebThumbQualityHD720, //Default
    MHWebThumbQualityMedium,
    MHWebThumbQualitySmall
};

typedef NS_ENUM(NSUInteger, MHYoutubeThumbQuality) {
    MHYoutubeThumbQualityHQ, //Default
    MHYoutubeThumbQualitySQ
};



@interface MHShareItem : NSObject
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,strong) NSString *title;
@property (nonatomic)        NSInteger maxNumberOfItems;
@property (nonatomic,strong) NSString *selectorName;
@property (nonatomic)        id onViewController;


- (id)initWithImageName:(NSString*)imageName
                  title:(NSString*)title
   withMaxNumberOfItems:(NSInteger)maxNumberOfItems
           withSelector:(NSString*)selectorName
       onViewController:(id)onViewController;

@end



@interface MHGalleryItem : NSObject

@property (nonatomic,strong) NSString           *urlString;
@property (nonatomic,strong) NSString           *description;
@property (nonatomic,strong) NSAttributedString *attributedString;
@property (nonatomic)        MHGalleryType       galleryType;

/**
 *  MHGalleryItem
 *
 *  @param urlString   the URL of the image or Video as a String
 *  @param galleryType select to Type, video or image
 *
 */

- (id)initWithURL:(NSString*)urlString
      galleryType:(MHGalleryType)galleryType;

@end

@interface MHGallerySharedManager : NSObject

@property (nonatomic,assign) UIStatusBarStyle oldStatusBarStyle;
/**
 *  default is MHYoutubeThumbQualityHQ
 */
@property (nonatomic,assign) MHYoutubeThumbQuality youtubeThumbQuality;
/**
 *  Default is MHVimeoThumbQualityLarge
 */
@property (nonatomic,assign) MHVimeoThumbQuality vimeoThumbQuality;
/**
 *  default is MHWebThumbQualityHD720
 */
@property (nonatomic,assign) MHWebThumbQuality webThumbQuality;
/**
 *  default is MHWebPointForThumbStart
 */
@property (nonatomic,assign) MHWebPointForThumb webPointForThumb;
/**
 *  default is MHVimeoVideoQualityHD
 */
@property (nonatomic,assign) MHVimeoVideoQuality vimeoVideoQuality;
/**
 *  default is MHYoutubeVideoQualityHD720
 */
@property (nonatomic,assign) MHYoutubeVideoQuality youtubeVideoQuality;

+ (MHGallerySharedManager *)sharedManager;
/**
 *  You can create a Thumbnail from a Video, you can create it from Videos from a Webserver, Youtube and Vimeo
 *
 *  @param urlString    URL as a string
 *  @param duration     the position on whicht the Thumbnail should be created
 *  @param succeedBlock returns the image the duration of the video and an error
 */
-(void)startDownloadingThumbImage:(NSString*)urlString
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL))succeedBlock;

- (UIImage *)imageByRenderingView:(id)view;

-(BOOL)isUIViewControllerBasedStatusBarAppearance;
/**
 *  To get the absolute URL for Vimeo Videos. To change the Quality check vimeoVideoQuality
 *
 *  @param URL          The URL as a String
 *  @param succeedBlock you will get the absolute URL
 */
-(void)getVimeoURLforMediaPlayer:(NSString*)URL
                    successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock;
/**
 *  To get the absolute URL for Youtube Videos. To change the Quality check youtubeVideoQuality
 *
 *  @param URL          The URL as a String
 *  @param succeedBlock you will get the absolute URL
 */
-(void)getYoutubeURLforMediaPlayer:(NSString*)URL
                      successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock;

-(void)getImageFromAssetLibrary:(NSString*)urlString
                      assetType:(MHAssetImageType)type
                   successBlock:(void (^)(UIImage *image,NSError *error))succeedBlock;
/**
 *  Returns all MHGalleryObjects for a Youtube channel
 *
 *  @param channelName  set the name of the channel
 *  @param withTitle    if you want the title of the video set it to YES
 *  @param succeedBlock returns the Gallery items
 */
-(void)getMHGalleryObjectsForYoutubeChannel:(NSString*)channelName
                                  withTitle:(BOOL)withTitle
                               successBlock:(void (^)(NSArray *MHGalleryObjects,NSError *error))succeedBlock;

@end

@interface MHGalleryController : UINavigationController

@property (nonatomic)        NSInteger presentationIndex;
@property (nonatomic,strong) UIImageView *presentingFromImageView;
@property (nonatomic,strong) MHGalleryImageViewerViewController *imageViewerViewController;
@property (nonatomic,strong) MHOverViewController *overViewViewController;
@property (nonatomic,strong) NSArray *galleryItems;
@property (nonatomic,strong) MHTransitionCustomization *transitionCustomization;
@property (nonatomic,strong) MHUICustomization *UICustomization;
@property (nonatomic,strong) MHTransitionPresentMHGallery *interactivePresentationTranstion;

- (id)initWithPresentationStyle:(MHGalleryPresentionStyle)presentationStyle;

@property (nonatomic, copy) void (^finishedCallback)(NSUInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition);

@end



@interface UIViewController(MHGalleryViewController)<UIViewControllerTransitioningDelegate>


-(void)presentMHGalleryController:(MHGalleryController*)galleryController
                         animated:(BOOL)animated
                       completion:(void (^)(void))completion;

- (void)dismissViewControllerAnimated:(BOOL)flag dismissImageView:(UIImageView*)dismissImageView completion:(void (^)(void))completion;

@end




