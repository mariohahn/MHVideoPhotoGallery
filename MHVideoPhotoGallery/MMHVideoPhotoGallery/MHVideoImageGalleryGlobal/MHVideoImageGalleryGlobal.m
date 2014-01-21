
#import "MHVideoImageGalleryGlobal.h"
#import "MHGalleryOverViewController.h"

NSString * const MHVimeoThumbBaseURL = @"http://vimeo.com/api/v2/video/%@.json";
NSString * const MHVimeoBaseURL = @"http://player.vimeo.com/v2/video/%@/config";
NSString * const MHGalleryViewModeOverView = @"MHGalleryViewModeOverView";
NSString * const MHGalleryViewModeShare = @"MHGalleryViewModeShare";
NSString * const MHUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";


@interface MHNavigationController : UINavigationController
@end

@implementation MHNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle {
    UIViewController *vc = [super childViewControllerForStatusBarStyle];
    vc = self.topViewController;
    return vc;
}
-(BOOL)shouldAutorotate{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
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
                  finishCallback:(void(^)(NSInteger pageIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition,UIImage *image)
                                  )FinishBlock
        withImageViewTransiation:(BOOL)animated{
    
    if(![MHGallerySharedManager sharedManager].viewModes){
        [MHGallerySharedManager sharedManager].viewModes = [NSSet setWithObjects:MHGalleryViewModeOverView,
                                                            MHGalleryViewModeShare, nil];
    }
    
    self.oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [[MHGallerySharedManager sharedManager] setGalleryItems:galleryItems];
    
    MHGalleryOverViewController *gallery = [MHGalleryOverViewController new];
    [gallery viewDidLoad];
    gallery.finishedCallback = ^(NSUInteger photoIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition,UIImage *image) {
        FinishBlock(photoIndex,interactiveTransition,image);
    };
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = index;
    detail.finishedCallback = ^(NSUInteger photoIndex,AnimatorShowDetailForDismissMHGallery *interactiveTransition,UIImage *image) {
        FinishBlock(photoIndex,interactiveTransition,image);
    };
    
    UINavigationController *nav = [MHNavigationController new];
    
    
    if (![[MHGallerySharedManager sharedManager].viewModes containsObject:MHGalleryViewModeOverView] || galleryItems.count ==1) {
        nav.viewControllers = @[detail];
    }else{
        nav.viewControllers = @[gallery,detail];
    }
    if (animated) {
        nav.transitioningDelegate = viewcontroller;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [viewcontroller presentViewController:nav animated:YES completion:nil];
}

-(BOOL)isUIVCBasedStatusBarAppearance{
    NSNumber *isUIVCBasedStatusBarAppearance = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isUIVCBasedStatusBarAppearance) {
        return  isUIVCBasedStatusBarAppearance.boolValue;
    }
    return YES;
}

-(void)createThumbURL:(NSString*)urlString
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
            CMTime thumbTime = CMTimeMakeWithSeconds(0,40);
            CMTime videoDurationTime = asset.duration;
            NSUInteger videoDurationTimeInSeconds = CMTimeGetSeconds(videoDurationTime);
            
            NSMutableDictionary *dictToSave = [self durationDict];
            if (videoDurationTimeInSeconds !=0) {
                dictToSave[urlString] = @(videoDurationTimeInSeconds);
                [self setObjectToUserDefaults:dictToSave];
            }
            
            if (duration == MHImageGenerationMiddle || duration == MHImageGenerationEnd) {
                if(duration == MHImageGenerationMiddle){
                    thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds/2,30);
                }else{
                    thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds,30);
                }
            }
            
            AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                
                if (result != AVAssetImageGeneratorSucceeded) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        succeedBlock(nil,0,error);
                    });
                }else{
                    [[SDImageCache sharedImageCache] storeImage:[UIImage imageWithCGImage:im]
                                                         forKey:urlString];
                    
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

-(void)getVimeoURLforMediaPlayer:(NSString*)URL
                    successBlock:(void (^)(NSString *URL,NSError *error))succeedBlock{
    
    NSString *videoID = [[URL componentsSeparatedByString:@"/"] lastObject];
    NSURL *vimdeoURL= [NSURL URLWithString:[NSString stringWithFormat:MHVimeoBaseURL, videoID]];
    
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:vimdeoURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:5];
    
    [httpRequest setValue:@"application/json"
       forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:httpRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSError *error;
                               
                               NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                        options:NSJSONReadingAllowFragments
                                                                                          error:&error];
                               
                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                   NSDictionary *filesInfo = [jsonData valueForKeyPath:@"request.files.h264"];
                                   if (!filesInfo) {
                                       succeedBlock(nil,nil);
                                   }
                                   NSDictionary *videoInfo =filesInfo[@"hd"];
                                   if (!videoInfo[@"url"]) {
                                       succeedBlock(nil,nil);
                                   }
                                   succeedBlock(videoInfo[@"url"],nil);
                               });
                           }];
}

-(void)setObjectToUserDefaults:(NSMutableDictionary*)dict{
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"MHGalleryData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(NSMutableDictionary*)durationDict{
    return [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"MHGalleryData"]];
}

-(void)getVimdeoThumbImage:(NSString*)URL
              successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock{
    
    NSString *videoID = [[URL componentsSeparatedByString:@"/"] lastObject];
    NSString *vimdeoURLString= [NSString stringWithFormat:MHVimeoThumbBaseURL, videoID];
    NSURL *vimdeoURL= [NSURL URLWithString:vimdeoURLString];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:vimdeoURLString];
    if (image) {
        NSMutableDictionary *dict = [self durationDict];
        succeedBlock(image,[dict[vimdeoURLString] integerValue],nil);
        return;
    }
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:vimdeoURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:httpRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSError *error;
                               NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:NSJSONReadingAllowFragments
                                                                                     error:&error];
                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                   if (jsonData.count) {
                                       if ([jsonData firstObject][@"thumbnail_large"]) {
                                           NSMutableDictionary *dictToSave = [self durationDict];
                                           dictToSave[vimdeoURLString] = @([jsonData[0][@"duration"] integerValue]);
                                           [self setObjectToUserDefaults:dictToSave];
                                           
                                           [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:jsonData[0][@"thumbnail_large"]]
                                                                                      options:SDWebImageContinueInBackground
                                                                                     progress:nil
                                                                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                                        succeedBlock(image,[jsonData[0][@"duration"] integerValue],nil);
                                                                                    }];
                                       }else{
                                           succeedBlock(nil,0,nil);
                                       }
                                       
                                   }else{
                                       succeedBlock(nil,0,nil);
                                   }
                               });
                           }];
    
}

-(void)startDownloadingThumbImage:(NSString*)urlString
                          forSize:(CGSize)size
                       atDuration:(MHImageGeneration)duration
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL))succeedBlock{
    
    if ([urlString rangeOfString:@"vimeo.com"].location != NSNotFound) {
        [self getVimdeoThumbImage:urlString
                     successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                         succeedBlock(image,videoDuration,error,urlString);
                     }];
        
    }else{
        [self createThumbURL:urlString
                     forSize:size
                  atDuration:duration
                successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                    succeedBlock(image,videoDuration,error,urlString);
                }];
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



