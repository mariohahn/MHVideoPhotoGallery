
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


/**
 *  Set the ViewModes for MHGallery, by default all ViewModes are on.
 */
extern NSString *const MHGalleryViewModeOverView;
extern NSString *const MHGalleryViewModeShare;
extern NSString *const MHVimeoBaseURL;
extern NSString *const MHVimeoThumbBaseURL;
extern NSString *const MHYoutubeInfoBaseURL;
extern NSString *const MHYoutubePlayBaseURL;
/**
 *  Is used to create Thumbnails from a video
 */
typedef NS_ENUM(NSUInteger, MHImageGeneration) {
    /**
     *  on postion 0 sec.
     */
    MHImageGenerationStart,
    /**
     *  on postion - videoDuration/2 sec.
     */
    MHImageGenerationMiddle,
    /**
     *  on postion - videoDuration sec.
     */
    MHImageGenerationEnd
};


/**
 *  The Type of the urlString from MHGalleryItem
 */
typedef NS_ENUM(NSUInteger, MHGalleryType) {
    /**
     *  Image
     */
    MHGalleryTypeImage,
    /**
     *  Video
     */
    MHGalleryTypeVideo
};

typedef NS_ENUM(NSUInteger, MHVimeoThumbQuality) {
    MHVimeoThumbQualityLarge, //Default
    MHVimeoThumbQualityMedium,
    MHVimeoThumbQualitySmall
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
@property (nonatomic,assign) BOOL isAnimatingWithCustomTransition;
@property (nonatomic,assign) MHYoutubeThumbQuality youtubeQuality;
@property (nonatomic,assign) MHVimeoThumbQuality vimeoQuality;

+ (MHGallerySharedManager *)sharedManager;


/**
 *  You can create a Thumbnail from a Image
 *
 *  @param urlString    URL as a string
 *  @param size         image size to return
 *  @param duration     the position on whicht the Thumbnail should be created
 *  @param succeedBlock returns the image the duration of the video and an error
 */
-(void)startDownloadingThumbImage:(NSString*)urlString
                          forSize:(CGSize)size
                       atDuration:(MHImageGeneration)duration
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL))succeedBlock;

- (UIImage *)imageByRenderingView:(id)view;


/**
 *  Use this methode to present the MHGallery
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
        withImageViewTransiation:(BOOL)animated;

-(BOOL)isUIVCBasedStatusBarAppearance;


-(void)getVimeoURLforMediaPlayer:(NSString*)URL
                    successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock;

-(void)getYoutubeURLforMediaPlayer:(NSString*)URL
                      successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock;

@end