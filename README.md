<p align="center" >
  <img src="https://dl.dropboxusercontent.com/u/17911939/galleryIcon.png" alt="MHGallery" title="MHGallery">
</p>
==================

## Podfile

```ruby
platform :ios, '7.0'
pod 'MHVideoPhotoGallery'
```
##Supported Videos
```ruby
Youtube
Vimeo
Weblinks (.mov, .mp4, .mpv)
```
##Supported Languages
```ruby
DE,EN,ES,FR,HR,IT,PT,RU
```
##MHGalleryItem 
```objective-c
+ (instancetype)itemWithURL:(NSString *)URLString thumbnailURL:(NSString*)thumbnailURL; //Thumbs are automatically generated for Videos. But you can set Thumb Images for GalleryTypeImage.
+ (instancetype)itemWithURL:(NSString*)URLString galleryType:(MHGalleryType)galleryType;
+ (instancetype)itemWithYoutubeVideoID:(NSString*)ID;
+ (instancetype)itemWithVimeoVideoID:(NSString*)ID;
+ (instancetype)itemWithImage:(UIImage*)image;
```

##MHGalleryController
```objective-c

+(instancetype)galleryWithPresentationStyle:(MHGalleryViewMode)presentationStyle;

@property (nonatomic,assign) id<MHGalleryDelegate>              galleryDelegate;
@property (nonatomic,assign) id<MHGalleryDataSource>            dataSource;
@property (nonatomic,assign) BOOL                               autoplayVideos; //Default NO
@property (nonatomic,assign) NSInteger                          presentationIndex; //From which index you want to present the Gallery.
@property (nonatomic,strong) UIImageView                        *presentingFromImageView;
@property (nonatomic,strong) MHGalleryImageViewerViewController *imageViewerViewController;
@property (nonatomic,strong) MHOverviewController               *overViewViewController;
@property (nonatomic,strong) NSArray                            *galleryItems; //You can set an Array of GalleryItems or you can use the dataSource.
@property (nonatomic,strong) MHTransitionCustomization          *transitionCustomization; //Use transitionCustomization to Customize the GalleryControllers transitions
@property (nonatomic,strong) MHUICustomization                  *UICustomization; //Use UICustomization to Customize the GalleryControllers UI
@property (nonatomic,strong) MHTransitionPresentMHGallery       *interactivePresentationTransition;
@property (nonatomic,assign) MHGalleryViewMode                  presentationStyle;
@property (nonatomic,assign) UIStatusBarStyle                   preferredStatusBarStyleMH;

@property (nonatomic, copy) void (^finishedCallback)(NSUInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode);

```


##UI Customization
```objective-c
@property (nonatomic)        UIBarStyle barStyle; //Default UIBarStyleDefault
@property (nonatomic,strong) UIColor *barTintColor; //Default nil
@property (nonatomic,strong) UIColor *barButtonsTintColor; //Default nil
@property (nonatomic,strong) UIColor *videoProgressTintColor; //Default Black
@property (nonatomic)        BOOL showMHShareViewInsteadOfActivityViewController; //Default YES
@property (nonatomic)        BOOL hideShare; //Default NO
@property (nonatomic)        BOOL useCustomBackButtonImageOnImageViewer; //Default YES
@property (nonatomic)        BOOL showOverView; //Default YES
@property (nonatomic)        MHBackButtonState backButtonState; //Default MHBackButtonStateWithBackArrow

@property (nonatomic,strong) UIBarButtonItem *customBarButtonItem; //A optional UIBarButtonItem displayed in the lower right corner. Default nil

@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutLandscape;
@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutPortrait;

-(void)setMHGalleryBackgroundColor:(UIColor*)color forViewMode:(MHGalleryViewMode)viewMode;
-(UIColor*)MHGalleryBackgroundColorForViewMode:(MHGalleryViewMode)viewMode;
```

##Transition Customization
```objective-c
@property (nonatomic)       BOOL interactiveDismiss; //Default YES
@property (nonatomic)       BOOL dismissWithScrollGestureOnFirstAndLastImage;//Default YES
@property (nonatomic)       BOOL fixXValueForDismiss; //Default NO
```

##Usage

```objective-c


UIImageView *imageView = [(ImageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] imageView];
        
MHGalleryItem *image1 = [MHGalleryItem itemWithURL:@"myImageURL" galleryType:MHGalleryTypeImage];
MHGalleryItem *image2 = [MHGalleryItem itemWithURL:@"myImageURL" galleryType:MHGalleryTypeImage];
MHGalleryItem *youtube = [MHGalleryItem itemWithYoutubeVideoID:@"myYoutubeID"];

NSArray *galleryData = @[image1,image2,youtube];
    
    MHGalleryController *gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
gallery.galleryItems = galleryData;
gallery.presentingFromImageView = imageView;    
gallery.presentationIndex = indexPath.row;
        
__weak MHGalleryController *blockGallery = gallery;
       
gallery.finishedCallback = ^(NSUInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition){
        
        NSIndexPath *newIndex = [NSIndexPath indexPathForRow:currentIndex inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = [(ImageTableViewCell*)[self.tableView cellForRowAtIndexPath:newIndex] iv];
            [blockGallery dismissViewControllerAnimated:YES dismissImageView:imageView completion:nil];
        });

    };    
[self presentMHGalleryController:gallery animated:YES completion:nil];
```

##Dismiss Video (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissInteractiveVideo.gif)

##Dismiss Image (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissInteractive.gif)

##Dismiss at the end or start on ScrollDirection (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissAtTheEnd.gif)

##OverView interactive (dismiss & present)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/interactive.gif)

##Share

![alt tag](https://dl.dropboxusercontent.com/u/17911939/ShareView.gif)

##OverView 

![alt tag](https://dl.dropboxusercontent.com/u/17911939/OverView.gif)

## Donating

Support this project via gittip.

<a href="https://www.gittip.com/mariohahn/">
  <img alt="Support via Gittip" src="https://rawgithub.com/twolfson/gittip-badge/0.2.0/dist/gittip.png"/>
</a>

	



[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/mariohahn/mhvideophotogallery/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

