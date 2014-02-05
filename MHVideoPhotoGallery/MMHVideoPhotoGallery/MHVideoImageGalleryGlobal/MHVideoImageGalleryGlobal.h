
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

#import "AnimatorShowDetailForDismissMHGallery.h"
#import "AnimatorShowDetailForPresentingMHGallery.h"

#define MHISIPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@class AnimatorShowDetailForDismissMHGallery;


extern NSString *const MHGalleryViewModeOverView;
extern NSString *const MHGalleryViewModeShare;
extern NSString *const MHVimeoBaseURL;
extern NSString *const MHVimeoThumbBaseURL;
extern NSString *const MHYoutubeInfoBaseURL;
extern NSString *const MHYoutubePlayBaseURL;

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
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic) MHGalleryType galleryType;
@property (nonatomic,strong) NSString *description;
@property (nonatomic,strong) NSString *title;


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

@property (nonatomic,strong) UIColor *barColor;
@property (nonatomic,strong) NSSet *viewModes;
@property (nonatomic,strong) NSArray *galleryItems;
@property (nonatomic,assign) UIStatusBarStyle oldStatusBarStyle;
@property (nonatomic,assign) BOOL animateWithCustomTransition;

@property (nonatomic,assign) MHYoutubeThumbQuality youtubeThumbQuality;
@property (nonatomic,assign) MHVimeoThumbQuality vimeoThumbQuality;
@property (nonatomic,assign) MHWebThumbQuality webThumbQuality;
@property (nonatomic,assign) MHWebPointForThumb webPointForThumb;


@property (nonatomic,assign) MHVimeoVideoQuality vimeoVideoQuality;
@property (nonatomic,assign) MHYoutubeVideoQuality youtubeVideoQuality;

@property (nonatomic,strong) AnimatorShowDetailForDismissMHGallery *interactiveMHGallery;
@property (nonatomic,strong) UIImageView *ivForPresentingAndDismissingMHGallery;

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


/**
 *  DEPRECATED use presentMHGalleryWithItems:forIndex:finishCallback:animated:
 *
 *  @param galleryItems   An array of MHGalleryItems
 *  @param index          The start index
 *  @param viewcontroller Your viewcontroller from which you present. Its used to set the transitioningDelegate delegate
 *  @param FinishBlock    PageIndex shows on which Index the User dismissed the Gallery. If interactiveTransition isn't nil the User dismisses the Gallery with an interaction. You will also get the Image of the current page.
 *  @param animated       To use animated you need 3 delegate Methods, -animationControllerForDismissedController , animationControllerForPresentedController, interactionControllerForDismissal.
 */
-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
        andCurrentViewController:(id)viewcontroller
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex, AnimatorShowDetailForDismissMHGallery *interactiveTransition,UIImage *image)
                                  )FinishBlock
        withImageViewTransiation:(BOOL)animated __attribute__((deprecated));

-(BOOL)isUIVCBasedStatusBarAppearance;

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

@end

@interface UIViewController(MHGalleryViewController)<UIViewControllerTransitioningDelegate>


/**
 *  Use this Methode to Present to MHGallery. If you want to animate it set the 'ivForPresentingAndDismissingMHGallery' from which you are presenting. In the FinishBlock you have to set ‘ivForPresentingAndDismissingMHGallery‘ again with the new ImageView.
 *
 *  @param galleryItems items you want to present
 *  @param index        index from which you want to present
 *  @param FinishBlock  returns the UINavigationController the currentPageIndex and the Image
 *  @param animated     if you want the custom transition set it to Yes.
 */
-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image)
                                  )FinishBlock
                        animated:(BOOL)animated;

@end

