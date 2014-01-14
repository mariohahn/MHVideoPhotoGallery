
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

typedef NS_ENUM(NSUInteger, MHImageGeneration) {
    MHImageGenerationStart,
    MHImageGenerationMiddle,
    MHImageGenerationEnd
};

typedef NS_ENUM(NSUInteger, MHGalleryTheme) {
    MHGalleryThemeBlack,
    MHGalleryThemeWhite
};

typedef NS_ENUM(NSUInteger, MHGalleryType) {
    MHGalleryTypeImage,
    MHGalleryTypeVideo
};

typedef NS_ENUM(NSUInteger, MHGalleryViewMode) {
    MHGalleryViewModeGridView,
    MHGalleryViewModeList
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

- (id)initWithURL:(NSString*)urlString
      galleryType:(MHGalleryType)galleryType;

@end


@interface MHGallerySharedManager : NSObject
@property (nonatomic,strong) NSArray *galleryItems;
@property (nonatomic) UIStatusBarStyle oldStatusBarStyle;

+ (MHGallerySharedManager *)sharedManager;


/**
 *  You can create
 *
 *  @param urlString    <#urlString description#>
 *  @param size         <#size description#>
 *  @param duration     <#duration description#>
 *  @param succeedBlock <#succeedBlock description#>
 */
-(void)startDownloadingThumbImage:(NSString*)urlString
                          forSize:(CGSize)size
                       atDuration:(MHImageGeneration)duration
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock;

- (UIImage *)imageByRenderingView:(id)view;

-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
        andCurrentViewController:(id)viewcontroller
                  finishCallback:(void(^)(NSInteger pageIndex, AnimatorShowDetailForDismissMHGallery *interactiveTransition,UIImage *image)
                                  )FinishBlock
        withImageViewTransiation:(BOOL)animated;



@end