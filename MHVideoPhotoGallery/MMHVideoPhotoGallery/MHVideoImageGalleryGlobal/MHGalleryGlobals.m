
#import "MHGalleryGlobals.h"
#import "MHOverViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDWebImageDecoder.h"
#import <objc/runtime.h>


NSString * const MHYoutubeChannel          = @"https://gdata.youtube.com/feeds/api/users/%@/uploads?&max-results=50&alt=json";
NSString * const MHYoutubePlayBaseURL      = @"https://www.youtube.com/get_video_info?video_id=%@&el=embedded&ps=default&eurl=&gl=US&hl=%@";
NSString * const MHYoutubeInfoBaseURL      = @"http://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=jsonc";
NSString * const MHVimeoThumbBaseURL       = @"http://vimeo.com/api/v2/video/%@.json";
NSString * const MHVimeoBaseURL            = @"http://player.vimeo.com/v2/video/%@/config";
NSString * const MHGalleryViewModeOverView = @"MHGalleryViewModeOverView";
NSString * const MHGalleryViewModeShare    = @"MHGalleryViewModeShare";


NSBundle *MHGalleryBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kMHGalleryBundleName];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

static NSString* (^ CustomLocalizationBlock)(NSString *localization) = nil;
static UIImage* (^ CustomImageBlock)(NSString *imageToChangeName) = nil;

void MHGalleryCustomImageBlock(UIImage *(^customImageBlock)(NSString *imageToChangeName)){
    CustomImageBlock = customImageBlock;
}
void MHGalleryCustomLocalizationBlock(NSString *(^customLocalizationBlock)(NSString *stringToLocalize)){
    CustomLocalizationBlock = customLocalizationBlock;
}

NSString *MHGalleryLocalizedString(NSString *localizeString) {
    if (CustomLocalizationBlock) {
        NSString *string = CustomLocalizationBlock(localizeString);
        if (string) {
            return string;
        }
    }
    return  NSLocalizedStringFromTableInBundle(localizeString, @"MHGallery", MHGalleryBundle(), @"");
}


UIImage *MHGalleryImage(NSString *imageName){
    if (CustomImageBlock) {
        UIImage *changedImage = CustomImageBlock(imageName);
        if (changedImage) {
            return changedImage;
        }
    }
    return [UIImage imageNamed:imageName];
}


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
    self.description = nil;
    self.galleryType = galleryType;
    self.attributedString = nil;
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

-(void)qualityForVideos{
    if (!self.youtubeThumbQuality) {
        self.youtubeThumbQuality = MHYoutubeThumbQualityHQ;
    }
    if (!self.vimeoThumbQuality) {
        self.vimeoThumbQuality = MHVimeoThumbQualityLarge;
    }
    if (!self.vimeoVideoQuality) {
        self.vimeoVideoQuality = MHVimeoVideoQualityHD;
    }
    if (!self.youtubeVideoQuality) {
        self.youtubeVideoQuality = MHYoutubeVideoQualityHD720;
    }
    if(!self.webThumbQuality){
        self.webThumbQuality = MHWebThumbQualityHD720;
    }
    if (!self.webPointForThumb) {
        self.webPointForThumb = MHWebPointForThumbStart;
    }
}
-(void)defaultViewModes{
    if(!self.viewModes){
        self.viewModes = [NSSet setWithObjects:MHGalleryViewModeOverView,
                          MHGalleryViewModeShare, nil];
    }
}

-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
        andCurrentViewController:(id)viewcontroller
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,MHAnimatorDismissMHGallery *interactiveTransition,UIImage *image)
                                  )FinishBlock
        withImageViewTransiation:(BOOL)animated{
    
    [self defaultViewModes];

    self.animateWithCustomTransition =animated;
    self.oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    self.galleryItems =galleryItems;
    
    MHOverViewController *gallery = [MHOverViewController new];
    [gallery viewDidLoad];
    gallery.finishedCallback = ^(UINavigationController *galleryNavMH,NSUInteger photoIndex,MHAnimatorDismissMHGallery *interactiveTransition,UIImage *image) {
        FinishBlock(galleryNavMH,photoIndex,interactiveTransition,image);
    };
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = index;
    detail.finishedCallback = ^(UINavigationController *galleryNavMH,NSUInteger photoIndex,MHAnimatorDismissMHGallery *interactiveTransition,UIImage *image) {
        FinishBlock(galleryNavMH,photoIndex,interactiveTransition,image);
    };
    
    UINavigationController *nav = [UINavigationController new];
    if (![self.viewModes containsObject:MHGalleryViewModeOverView] || galleryItems.count ==1) {
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
-(void)getImageFromAssetLibrary:(NSString*)urlString
                      assetType:(MHAssetImageType)type
                   successBlock:(void (^)(UIImage *image,NSError *error))succeedBlock{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        ALAssetsLibrary *assetslibrary = [ALAssetsLibrary new];
        [assetslibrary assetForURL:[NSURL URLWithString:urlString]
                       resultBlock:^(ALAsset *asset){
                           
                           if (type == MHAssetImageTypeThumb) {
                               dispatch_sync(dispatch_get_main_queue(), ^(void){
                                   UIImage *image = [[UIImage alloc]initWithCGImage:asset.thumbnail];
                                   succeedBlock(image,nil);
                               });
                           }else{
                               ALAssetRepresentation *rep = [asset defaultRepresentation];
                               CGImageRef iref = [rep fullScreenImage];
                               if (iref) {
                                   dispatch_sync(dispatch_get_main_queue(), ^(void){
                                       UIImage *image = [[UIImage alloc]initWithCGImage:iref];
                                       succeedBlock(image,nil);
                                   });
                               }
                           }
                       }
                      failureBlock:^(NSError *error) {
                          dispatch_sync(dispatch_get_main_queue(), ^(void){
                              succeedBlock(nil,error);
                          });
                      }];
    });
}


-(void)setIvForPresentingAndDismissingMHGallery:(UIImageView *)ivForPresentingAndDismissingMHGallery{
    if (self.interactiveDismissMHGallery) {
        self.interactiveDismissMHGallery.iv = ivForPresentingAndDismissingMHGallery;
    }
    _ivForPresentingAndDismissingMHGallery = ivForPresentingAndDismissingMHGallery;
}


-(BOOL)isUIVCBasedStatusBarAppearance{
    NSNumber *isUIVCBasedStatusBarAppearance = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isUIVCBasedStatusBarAppearance) {
        return  isUIVCBasedStatusBarAppearance.boolValue;
    }
    return YES;
}

-(void)createThumbURL:(NSString*)urlString
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
            if(self.webPointForThumb == MHWebPointForThumbStart){
                thumbTime = CMTimeMakeWithSeconds(0,40);
            }else if(self.webPointForThumb == MHWebPointForThumbMiddle){
                thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds/2,40);
            }else if(self.webPointForThumb == MHWebPointForThumbEnd){
                thumbTime = CMTimeMakeWithSeconds(videoDurationTimeInSeconds,40);
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
            if (self.webThumbQuality == MHWebThumbQualityHD720) {
                generator.maximumSize = CGSizeMake(720, 720);
            }else if (self.webThumbQuality == MHWebThumbQualityMedium) {
                generator.maximumSize = CGSizeMake(420 ,420);
            }else if(self.webThumbQuality == MHWebThumbQualitySmall) {
                generator.maximumSize = CGSizeMake(220 ,220);
            }
            [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:thumbTime]]
                                            completionHandler:handler];
        });
    }
}

-(NSString*)languageIdentifier{
	static NSString *applicationLanguageIdentifier;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		applicationLanguageIdentifier = @"en";
		NSArray *preferredLocalizations = [[NSBundle mainBundle] preferredLocalizations];
		if (preferredLocalizations.count > 0)
			applicationLanguageIdentifier = [NSLocale canonicalLanguageIdentifierFromString:preferredLocalizations[0]] ?: applicationLanguageIdentifier;
	});
	return applicationLanguageIdentifier;
}

-(NSDictionary*)getURLParFromURL:(NSString*)URL{
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSArray *fields = [URL componentsSeparatedByString:@"&"];
	for (NSString *field in fields){
		NSArray *pair = [field componentsSeparatedByString:@"="];
		if (pair.count == 2){
			NSString *key = pair[0];
			NSString *value = [pair[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
			dict[key] = value;
		}
	}
	return dict;
}

-(void)getYoutubeURLforMediaPlayer:(NSString*)URL
                      successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock{
    
    NSString *videoID = [[URL componentsSeparatedByString:@"?v="] lastObject];
    NSURL *videoInfoURL = [NSURL URLWithString:[NSString stringWithFormat:MHYoutubePlayBaseURL, videoID ?: @"", [self languageIdentifier]]];
    NSMutableURLRequest *httpRequest = [[NSMutableURLRequest alloc] initWithURL:videoInfoURL
                                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                timeoutInterval:10];
    [httpRequest setValue:[self languageIdentifier] forHTTPHeaderField:@"Accept-Language"];
    [NSURLConnection sendAsynchronousRequest:httpRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               dispatch_async(dispatch_get_main_queue(), ^(void){
                                   NSURL *playURL = [self getYoutubeURLWithData:data];
                                   if (playURL) {
                                       succeedBlock(playURL,nil);
                                   }else{
                                       succeedBlock(nil,nil);
                                   }
                               });
                           }];
}



- (NSURL *)getYoutubeURLWithData:(NSData *)data{
    
	NSString *videoData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
	NSDictionary *video = [self getURLParFromURL:videoData];
	NSArray *videoURLS = [video[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","];
	NSMutableDictionary *streamURLs = [NSMutableDictionary new];
	for (NSString *videoURL in videoURLS){
		NSDictionary *stream = [self getURLParFromURL:videoURL];
		NSString *type = stream[@"type"];
		NSString *urlString = stream[@"url"];
		NSString *signatureString = stream[@"sig"];
		if (urlString && signatureString && [AVURLAsset isPlayableExtendedMIMEType:type]){
			NSURL *streamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@&signature=%@", urlString, signatureString]];
			streamURLs[@([stream[@"itag"] integerValue])] = streamURL;
		}
	}
    if (self.youtubeVideoQuality == MHYoutubeVideoQualityHD720) {
        if (streamURLs[@(22)]) {
            return streamURLs[@(22)];
        }
    }
    
    if (self.youtubeVideoQuality == MHYoutubeVideoQualityHD720 || self.youtubeVideoQuality == MHYoutubeVideoQualityMedium) {
        if (streamURLs[@(18)]) {
            return streamURLs[@(18)];
        }
    }
    if(self.youtubeVideoQuality == MHYoutubeVideoQualitySmall){
        if (streamURLs[@(36)]) {
            return streamURLs[@(36)];
        }
    }
    
	return nil;
}
-(void)getVimeoURLforMediaPlayer:(NSString*)URL
                    successBlock:(void (^)(NSURL *URL,NSError *error))succeedBlock{
    
    NSString *videoID = [[URL componentsSeparatedByString:@"/"] lastObject];
    NSURL *vimdeoURL= [NSURL URLWithString:[NSString stringWithFormat:MHVimeoBaseURL, videoID]];
    
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:vimdeoURL
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:10];
    
    [httpRequest setValue:@"application/json"
       forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:httpRequest
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSError *error;
                                   
                                   NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                            options:NSJSONReadingAllowFragments
                                                                                              error:&error];
                                   dispatch_async(dispatch_get_main_queue(), ^(void){
                                       NSDictionary *filesInfo = [jsonData valueForKeyPath:@"request.files.h264"];
                                       if (!filesInfo) {
                                           succeedBlock(nil,nil);
                                       }
                                       NSString *quality = [NSString new];
                                       if (self.vimeoVideoQuality == MHVimeoVideoQualityHD) {
                                           quality = @"hd";
                                           if(!filesInfo[quality]){
                                               quality = @"sd";
                                           }
                                       } else if (self.vimeoVideoQuality == MHVimeoVideoQualityMobile){
                                           quality = @"mobile";
                                       }else if(self.vimeoVideoQuality == MHVimeoVideoQualitySD){
                                           quality = @"sd";
                                       }
                                       NSDictionary *videoInfo =filesInfo[quality];
                                       if (!videoInfo[@"url"]) {
                                           succeedBlock(nil,nil);
                                       }
                                       succeedBlock([NSURL URLWithString:videoInfo[@"url"]],nil);
                                   });
                               }else{
                                   succeedBlock(nil,connectionError);
                               }
                               
                           }];
}

-(void)setObjectToUserDefaults:(NSMutableDictionary*)dict{
    [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"MHGalleryData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(NSMutableDictionary*)durationDict{
    return [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:@"MHGalleryData"]];
}


-(void)getYoutubeThumbImage:(NSString*)URL
               successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error))succeedBlock{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:URL];
    if (image) {
        NSMutableDictionary *dict = [self durationDict];
        succeedBlock(image,[dict[URL] integerValue],nil);
    }else{
        NSString *videoID = [[URL componentsSeparatedByString:@"?v="] lastObject];
        NSString *infoURL = [NSString stringWithFormat:MHYoutubeInfoBaseURL,videoID];
        NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:infoURL]
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10];
        [NSURLConnection sendAsynchronousRequest:httpRequest
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (!connectionError) {
                                       NSError *error;
                                       NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:NSJSONReadingAllowFragments
                                                                                                  error:&error];
                                       dispatch_async(dispatch_get_main_queue(), ^(void){
                                           if (jsonData.count) {
                                               NSMutableDictionary *dictToSave = [self durationDict];
                                               dictToSave[URL] = @([jsonData[@"data"][@"duration"] integerValue]);
                                               [self setObjectToUserDefaults:dictToSave];
                                               NSString *thumbURL = [NSString new];
                                               if (self.youtubeThumbQuality == MHYoutubeThumbQualityHQ) {
                                                   thumbURL = jsonData[@"data"][@"thumbnail"][@"hqDefault"];
                                               }else if (self.youtubeThumbQuality == MHYoutubeThumbQualitySQ){
                                                   thumbURL = jsonData[@"data"][@"thumbnail"][@"sqDefault"];
                                               }
                                               [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:thumbURL]
                                                                                          options:SDWebImageContinueInBackground
                                                                                         progress:nil
                                                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                                            
                                                                                            [[SDImageCache sharedImageCache] removeImageForKey:thumbURL];
                                                                                            [[SDImageCache sharedImageCache] storeImage:image
                                                                                                                                 forKey:URL];
                                                                                            
                                                                                            succeedBlock(image,[jsonData[@"data"][@"duration"] integerValue],nil);
                                                                                        }];
                                           }
                                       });
                                   }else{
                                       succeedBlock(nil,0,connectionError);
                                   }
                               }];
    }
    
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
    }else{
        NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:vimdeoURL
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:10];
        [NSURLConnection sendAsynchronousRequest:httpRequest
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (connectionError) {
                                       succeedBlock(nil,0,connectionError);
                                   }else{
                                       NSError *error;
                                       NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:NSJSONReadingAllowFragments
                                                                                             error:&error];
                                       dispatch_async(dispatch_get_main_queue(), ^(void){
                                           if (jsonData.count) {
                                               
                                               __block NSString *quality = [NSString new];
                                               if (self.vimeoThumbQuality == MHVimeoThumbQualityLarge) {
                                                   quality = @"thumbnail_large";
                                               } else if (self.vimeoThumbQuality == MHVimeoThumbQualityMedium){
                                                   quality = @"thumbnail_medium";
                                               }else if(self.vimeoThumbQuality == MHVimeoThumbQualitySmall){
                                                   quality = @"thumbnail_small";
                                               }
                                               if ([jsonData firstObject][quality]) {
                                                   NSMutableDictionary *dictToSave = [self durationDict];
                                                   dictToSave[vimdeoURLString] = @([jsonData[0][@"duration"] integerValue]);
                                                   [self setObjectToUserDefaults:dictToSave];
                                                   
                                                   [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:jsonData[0][quality]]
                                                                                              options:SDWebImageContinueInBackground
                                                                                             progress:nil
                                                                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                                                [[SDImageCache sharedImageCache] removeImageForKey:jsonData[0][quality]];
                                                                                                [[SDImageCache sharedImageCache] storeImage:image
                                                                                                                                     forKey:vimdeoURLString];
                                                                                                
                                                                                                succeedBlock(image,[jsonData[0][@"duration"] integerValue],nil);
                                                                                            }];
                                               }else{
                                                   succeedBlock(nil,0,nil);
                                               }
                                               
                                           }else{
                                               succeedBlock(nil,0,nil);
                                           }
                                       });
                                   }
                                   
                                   
                               }];
    }
    
}

-(void)startDownloadingThumbImage:(NSString*)urlString
                     successBlock:(void (^)(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL))succeedBlock{
    if ([urlString rangeOfString:@"vimeo.com"].location != NSNotFound) {
        [self getVimdeoThumbImage:urlString
                     successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                         succeedBlock(image,videoDuration,error,urlString);
                     }];
    }else if([urlString rangeOfString:@"youtube.com"].location != NSNotFound) {
        [self getYoutubeThumbImage:urlString
                      successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                          succeedBlock(image,videoDuration,error,urlString);
                      }];
    }else{
        [self createThumbURL:urlString
                successBlock:^(UIImage *image, NSUInteger videoDuration, NSError *error) {
                    succeedBlock(image,videoDuration,error,urlString);
                }];
    }
}


-(void)getMHGalleryObjectsForYoutubeChannel:(NSString*)channelName
                                  withTitle:(BOOL)withTitle
                               successBlock:(void (^)(NSArray *MHGalleryObjects,NSError *error))succeedBlock{
    NSMutableURLRequest *httpRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:MHYoutubeChannel,channelName]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [NSURLConnection sendAsynchronousRequest:httpRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            succeedBlock(nil,connectionError);
            
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                NSError *error = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
                if (!error) {
                    NSMutableArray *galleryData = [NSMutableArray new];
                    for (NSDictionary *dictionary in dict[@"feed"][@"entry"]) {
                        NSString *string = [dictionary[@"link"] firstObject][@"href"];
                        
                        string = [string stringByReplacingOccurrencesOfString:@"&feature=youtube_gdata" withString:@""];
                        MHGalleryItem *item = [[MHGalleryItem alloc]initWithURL:string galleryType:MHGalleryTypeVideo];
                        if (withTitle) {
                            item.description = dictionary[@"title"][@"$t"];
                        }
                        [galleryData addObject:item];
                    }
                    succeedBlock(galleryData,nil);
                }else{
                    succeedBlock(nil,error);
                }
            });
        }
    }];
    
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

@implementation UIViewController(MHGalleryViewController)

-(void)presentMHGalleryOverViewWithItems:(NSArray*)galleryItems
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image)
                                  )FinishBlock
                                customAnimationFromImage:(BOOL)animated{
   
    [[MHGallerySharedManager sharedManager] qualityForVideos];
    [[MHGallerySharedManager sharedManager] defaultViewModes];

    [MHGallerySharedManager sharedManager].animateWithCustomTransition =animated;
    [MHGallerySharedManager sharedManager].oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [MHGallerySharedManager sharedManager].galleryItems =galleryItems;
   
    MHOverViewController *gallery = [MHOverViewController new];
    [gallery viewDidLoad];
    gallery.finishedCallback = ^(UINavigationController *galleryNavMH,NSUInteger photoIndex,MHAnimatorDismissMHGallery *interactiveTransition,UIImage *image) {
        [MHGallerySharedManager sharedManager].interactiveDismissMHGallery = interactiveTransition;
        FinishBlock(galleryNavMH,photoIndex,image);
    };
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:gallery];
    if (animated) {
        nav.transitioningDelegate = self;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:nav animated:YES completion:nil];
}


-(void)presentMHGalleryWithItems:(NSArray*)galleryItems
                        forIndex:(NSInteger)index
                  finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image)
                                  )FinishBlock
                        customAnimationFromImage:(BOOL)animated{
    
    [[MHGallerySharedManager sharedManager] qualityForVideos];
    [[MHGallerySharedManager sharedManager] defaultViewModes];

    [MHGallerySharedManager sharedManager].animateWithCustomTransition =animated;
    [MHGallerySharedManager sharedManager].oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    [MHGallerySharedManager sharedManager].galleryItems =galleryItems;
    
    MHOverViewController *gallery = [MHOverViewController new];
    [gallery viewDidLoad];
    gallery.finishedCallback = ^(UINavigationController *galleryNavMH,NSUInteger photoIndex,MHAnimatorDismissMHGallery *interactiveTransition,UIImage *image) {
        [MHGallerySharedManager sharedManager].interactiveDismissMHGallery = interactiveTransition;
        FinishBlock(galleryNavMH,photoIndex,image);
    };
    
    MHGalleryImageViewerViewController *detail = [MHGalleryImageViewerViewController new];
    detail.pageIndex = index;
    detail.finishedCallback = ^(UINavigationController *galleryNavMH,NSUInteger photoIndex,MHAnimatorDismissMHGallery *interactiveTransition,UIImage *image) {
        [MHGallerySharedManager sharedManager].interactiveDismissMHGallery = interactiveTransition;
        FinishBlock(galleryNavMH,photoIndex,image);
    };
    
    UINavigationController *nav = [UINavigationController new];
    if (![[MHGallerySharedManager sharedManager].viewModes containsObject:MHGalleryViewModeOverView] || galleryItems.count ==1) {
        nav.viewControllers = @[detail];
    }else{
        nav.viewControllers = @[gallery,detail];
    }
    if (animated) {
        nav.transitioningDelegate = self;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self presentViewController:nav animated:YES completion:nil];
}


-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    if ([animator isKindOfClass:[MHAnimatorPresentMHGallery class]]) {
        return [MHGallerySharedManager sharedManager].ivForInteractiveTransition.presenter;
    }else {
        return nil;
    }
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    if ([animator isKindOfClass:[MHAnimatorDismissMHGallery class]]) {
        
        MHAnimatorDismissMHGallery *animatorDismiss = (MHAnimatorDismissMHGallery*)animator;
        if (animatorDismiss.interactive) {
            return [MHGallerySharedManager sharedManager].interactiveDismissMHGallery;
        }
        return nil;
    }else {
        return nil;
    }
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    MHAnimatorDismissMHGallery *detail = [MHGallerySharedManager sharedManager].interactiveDismissMHGallery;
    detail.iv = [MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery;
    return detail;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    UINavigationController *nav = (UINavigationController*)presented;
    if ([nav.viewControllers.lastObject  isKindOfClass:[MHGalleryImageViewerViewController class]]) {
        MHAnimatorPresentMHGallery *detail = [MHAnimatorPresentMHGallery new];
        detail.iv = [MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery;
        return detail;
    }
    return nil;
}

@end


