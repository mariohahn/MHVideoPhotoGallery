
#import "MHVideoImageGalleryGlobal.h"
#import "MHGalleryOverViewController.h"

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
                  finishCallback:(void(^)(NSInteger pageIndex)
                                  )FinishBlock
        withImageViewTransiation:(BOOL)animated{
    
    [[MHGallerySharedManager sharedManager] setGalleryItems:galleryItems];
    
    MHGalleryOverViewController *gallery = [MHGalleryOverViewController new];
    [gallery viewDidLoad];
    gallery.finishedCallback = ^(NSUInteger photoIndex) {
        FinishBlock(photoIndex);
    };
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = index;
    
    UINavigationController *nav = [UINavigationController new];
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
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration))succeedBlock{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlString];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"MHGalleryData"]];
    if (!dict) {
        dict = [NSMutableDictionary new];
    }
    if (image) {
        succeedBlock(image,[dict[urlString] integerValue]);
    }else{
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSURL *url = [NSURL URLWithString:urlString];
            AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
            
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
            CMTime videoDurationTime = asset.duration;
            NSUInteger videoDurationTimeInSeconds = CMTimeGetSeconds(videoDurationTime);
            
            dict[urlString] = @(videoDurationTimeInSeconds);
            
            [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"MHGalleryData"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            
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
                }else{
                    [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithCGImage:im]  forKey:urlString];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        succeedBlock([UIImage imageWithCGImage:im],videoDurationTimeInSeconds);
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



