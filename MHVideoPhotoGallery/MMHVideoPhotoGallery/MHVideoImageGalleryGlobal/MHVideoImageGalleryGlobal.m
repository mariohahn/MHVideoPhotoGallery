
#import "MHVideoImageGalleryGlobal.h"
#import "MHGalleryOverViewController.h"

@interface MHNavigationController : UINavigationController
@end

@implementation MHNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *vc = [super childViewControllerForStatusBarStyle];
    vc = self.topViewController;
    return vc;
}

@end

@implementation MHShareItem


- (id)initWithImageName:(NSString*)imageName
                  title:(NSString*)title
           withMaxNumberOfItems:(NSInteger)maxNumberOfItems
           withSelector:(NSString*)selectorName
       onViewController:(id)onViewController{
    self = [super init];
    if (!self)
        return nil;
    self.imageName = imageName;
    self.title = title;
    self.maxNumberOfItems = maxNumberOfItems;
    self.selectorName = selectorName;
    self.onViewController = onViewController;
    return self;
}
@end

@implementation MHGalleryItem


- (id)initWithURL:(NSString*)urlString
      galleryType:(MHGalleryType)galleryType{
    self = [super init];
    if (!self)
        return nil;
    self.urlString = urlString;
    self.title = nil;
    self.description = nil;
    self.galleryType = galleryType;
    return self;
}
@end


@implementation MHGallerySharedManager

+ (MHGallerySharedManager *)sharedManager{
    static MHGallerySharedManager *sharedManagerInstance = nil;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
        andCurrentViewController:(id)viewcontroller
                  finishCallback:(void(^)(NSInteger pageIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition)
                                  )FinishBlock
        withImageViewTransiation:(BOOL)animated{
    
    self.oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;

    [[MHGallerySharedManager sharedManager] setGalleryItems:galleryItems];
    
    MHGalleryOverViewController *gallery = [MHGalleryOverViewController new];
    [gallery viewDidLoad];
    gallery.finishedCallback = ^(NSUInteger photoIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition) {
        FinishBlock(photoIndex,interactiveTransition);
    };
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = index;
    
    UINavigationController *nav = [MHNavigationController new];
    nav.viewControllers = @[gallery,detail];
    if (animated) {
        nav.transitioningDelegate = viewcontroller;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [viewcontroller presentViewController:nav animated:YES completion:nil];
}

-(void)startDownloadingThumbImage:(NSString*)urlString
                          forSize:(CGSize)size
                       atDuration:(MHImageGeneration)duration
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"MHGalleryData"]];
    if (!dict) {
        dict = [NSMutableDictionary new];
    }
    if (image) {
        succeedBlock(image,[dict[urlString] integerValue],nil);
    }else{
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSURL *url = [NSURL URLWithString:urlString];
            AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
            
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
            CMTime videoDurationTime = asset.duration;
            NSUInteger videoDurationTimeInSeconds = CMTimeGetSeconds(videoDurationTime);
            
            dict[urlString] = @(videoDurationTimeInSeconds);

            
            if (duration == MHImageGenerationMiddle || duration == MHImageGenerationEnd) {
                if(duration == MHImageGenerationMiddle){
                    thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds/2,30);
                }else{
                    thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds,30);
                }
            }
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                
                NSString *requestedTimeString = (NSString *)
                CFBridgingRelease(CMTimeCopyDescription(NULL, requestedTime));
                NSString *actualTimeString = (NSString *)
                CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
                NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
                
                if (result != AVAssetImageGeneratorSucceeded) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        succeedBlock(nil,0,error);
                    });

                }else{
                    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"MHGalleryData"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithCGImage:im]  forKey:urlString];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        succeedBlock([UIImage imageWithCGImage:im],videoDurationTimeInSeconds,nil);
                    });
                }
            };
            CGSize maxSize = size;
            generator.maximumSize = maxSize;
            [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:thumbTime]]
                                            completionHandler:handler];
        });
    }
}


- (UIImage *)imageByRenderingView:(id)view{
    CGFloat scale = 1.0;
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)]) {
        CGFloat tmp = [[UIScreen mainScreen]scale];
        if (tmp > 1.5) {
            scale = 2.0;
        }
    }
    if(scale > 1.5) {
        UIGraphicsBeginImageContextWithOptions([view bounds].size, NO, scale);
    } else {
        UIGraphicsBeginImageContext([view bounds].size);
    }
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end



