<p align="center" >
  <img src="https://dl.dropboxusercontent.com/u/17911939/galleryIcon.png" alt="MHGallery" title="MHGallery">
</p>
==================

#### Podfile

```ruby
platform :ios, '7.0'
pod 'MHVideoPhotoGallery', '~> 1.6'
```
####Supported Videos
```ruby
Youtube
Vimeo
Weblinks (.mov, .mp4, .mpv)
```
####Supported Languages
```ruby
DE,EN,ES,FR,HR
```
####UI Customization
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

@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutLandscape;
@property (nonatomic,strong) UICollectionViewFlowLayout *overViewCollectionViewLayoutPortrait;

-(void)setMHGalleryBackgroundColor:(UIColor*)color forViewMode:(MHGalleryViewMode)viewMode;
-(UIColor*)MHGalleryBackgroundColorForViewMode:(MHGalleryViewMode)viewMode;
```

####Transition Customization
```objective-c
@property (nonatomic)       BOOL interactiveDismiss;
@property (nonatomic)       BOOL dismissWithScrollGestureOnFirstAndLastImage;
@property (nonatomic)       BOOL fixXValueForDismiss;
```

####Dismiss Video (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissInteractiveVideo.gif)

####Dismiss Image (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissInteractive.gif)

####Dismiss at the end or start on ScrollDirection (Like Paper App)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/dismissAtTheEnd.gif)

####OverView interactive (dismiss & present)

![alt tag](https://dl.dropboxusercontent.com/u/17911939/interactive.gif)

####Share

![alt tag](https://dl.dropboxusercontent.com/u/17911939/ShareView.gif)

####OverView 

![alt tag](https://dl.dropboxusercontent.com/u/17911939/OverView.gif)


####How to use

```objective-c


UIImageView *imageView = [(ImageTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] iv];
        
MHGalleryItem *image1 = [[MHGalleryItem alloc]initWithURL:@"http://p1.pichost.me/i/40/1638707.jpg"
                                                       galleryType:MHGalleryTypeImage];
    
MHGalleryItem *image2 = [[MHGalleryItem alloc]initWithURL:@"http://4.bp.blogspot.com/-8O0ZkAgb6Bo/Ulf_80tUN6I/AAAAAAAAH34/I1L2lKjzE9M/s1600/Beautiful-Scenery-Wallpapers.jpg"
                                                       galleryType:MHGalleryTypeImage];

NSArray *galleryData = @[image1,image2];
    
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

	

