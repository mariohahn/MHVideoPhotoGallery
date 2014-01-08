//
//  MHGalleryImageViewerViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//


#import "MHGalleryImageViewerViewController.h"

@interface MHGalleryImageViewerViewController()
@property (nonatomic, strong) NSArray *galleryItems;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) UIBarButtonItem *share;
@property (nonatomic, strong) UIBarButtonItem *left;
@property (nonatomic, strong) UIBarButtonItem *right;
@property (nonatomic, strong) UIBarButtonItem *playStopButton;
@property (nonatomic, strong) ImageViewController *ivC;
@property(nonatomic,getter = isHiddingToolBarAndNavigationBar)BOOL hiddingToolBarAndNavigationBar;
@end

@implementation MHGalleryImageViewerViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

-(void)donePressed{
    MHGalleryOverViewController *overView  =[self.navigationController.viewControllers firstObject];
    overView.finishedCallback(self.pageIndex);
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.galleryItems = [MHGallerySharedManager sharedManager].galleryItems;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.pvc =[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                             options:@{ UIPageViewControllerOptionInterPageSpacingKey : @30.f }];
    self.pvc.delegate = self;
    self.pvc.dataSource = self;
    [self.pvc setAutomaticallyAdjustsScrollViewInsets:NO];
    
    MHGalleryItem *item = self.galleryItems[self.pageIndex];
    
    ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:item];
    ivC.pageIndex = self.pageIndex;
    [ivC setValue:self forKey:@"vc"];


    
    [self.pvc setViewControllers:@[ivC]
                  direction:UIPageViewControllerNavigationDirectionForward
                   animated:NO
                 completion:nil];
    
    
    [self addChildViewController:self.pvc];
    [self.pvc didMoveToParentViewController:self];
    [self.view addSubview:[self.pvc view]];
    
    self.tb = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    self.tb.tag = 307;
    self.tb.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    self.playStopButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playStopButtonPressed)];

    self.left = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"left_arrow"] style:UIBarButtonItemStyleBordered target:self action:@selector(leftPressed:)];
    
    self.right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"right_arrow"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightPressed:)];
    
    self.share = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    if (item.galleryType == MHGalleryTypeVideo) {
        self.playStopButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playStopButtonPressed)];
        [self.tb setItems:@[self.share,flex,self.left,flex,self.playStopButton,flex,self.right,flex]];
    }else{
        [self.tb setItems:@[self.share,flex,self.left,flex,self.right,flex]];
    }
    
    if (self.pageIndex == 0) {
        [self.left setEnabled:NO];
    }
    if(self.pageIndex == self.galleryItems.count-1){
        [self.right setEnabled:NO];
    }
    
    self.descriptionViewBackground = [[UIToolbar alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.descriptionViewBackground];
    
    self.descriptionView = [[UITextView alloc]initWithFrame:CGRectZero];
    self.descriptionView.backgroundColor = [UIColor clearColor];
    self.descriptionView.font = [UIFont systemFontOfSize:15];
    self.descriptionView.text = item.description;
    self.descriptionView.textColor = [UIColor blackColor];
    [self.descriptionView setUserInteractionEnabled:NO];
    [self.view addSubview:self.descriptionView];
    
    
    
    CGSize size = [self.descriptionView sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];

    self.descriptionView.frame = CGRectMake(10, self.view.frame.size.height -size.height-44, self.view.frame.size.width-20, size.height);
    if (self.descriptionView.text.length >0) {
        self.descriptionViewBackground.frame = CGRectMake(0, self.view.frame.size.height -size.height-44, self.view.frame.size.width, size.height);
    }else{
        [self.descriptionViewBackground setHidden:YES];
    }
    [(UIScrollView*)self.pvc.view.subviews[0] setDelegate:self];
   // [(UIScrollView*)self.pvc.view.subviews[0] setDelaysContentTouches:NO];
    [self updateTitleForIndex:self.pageIndex];
    [self.view addSubview:self.tb];

}

-(void)changeToPlayButton{
    self.playStopButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playStopButtonPressed)];
    [self updateToolBarForItem:self.galleryItems[self.pageIndex]];
}

-(void)changeToPauseButton{
    self.playStopButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playStopButtonPressed)];
    [self updateToolBarForItem:self.galleryItems[self.pageIndex]];
}

-(void)playStopButtonPressed{
    for (ImageViewController *ivC in self.pvc.viewControllers) {
        if (ivC.pageIndex == self.pageIndex) {
            if (ivC.isPlayingVideo) {
                [ivC stopMovie];
                self.playStopButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playStopButtonPressed)];
                [self updateToolBarForItem:self.galleryItems[self.pageIndex]];
            }else{
                
                [self.playStopButton setEnabled:NO];
                [ivC playButtonPressed];
            }
        }
    }
}

-(void)sharePressed{
    
    MHGalleryItem *item = self.galleryItems[self.pageIndex];
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[item.urlString,item.description]
                                                                    applicationActivities:nil];
    [self presentViewController:self.activityViewController
                       animated:YES
                     completion:nil];
    
}

-(void)updateDescriptionLabelForIndex:(NSInteger)index{
   MHGalleryItem *item = self.galleryItems[index];
   self.descriptionView.text = item.description;
   CGSize size = [self.descriptionView sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];
    
   self.descriptionView.frame = CGRectMake(10, self.view.frame.size.height -size.height-44, self.view.frame.size.width-20, size.height);
    if (self.descriptionView.text.length >0) {
        [self.descriptionViewBackground setHidden:NO];
        self.descriptionViewBackground.frame = CGRectMake(0, self.view.frame.size.height -size.height-44, self.view.frame.size.width, size.height);
    }else{
        [self.descriptionViewBackground setHidden:YES];
    }

}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    NSInteger pageIndex =self.pageIndex;
    [self updateDescriptionLabelForIndex:pageIndex];

    if (scrollView.contentOffset.x > (self.view.frame.size.width+self.view.frame.size.width/2)) {
        pageIndex++;
        [self updateDescriptionLabelForIndex:pageIndex];
    }
    if (scrollView.contentOffset.x < self.view.frame.size.width/2) {
        pageIndex--;
        [self updateDescriptionLabelForIndex:pageIndex];
    }
    [self updateTitleForIndex:pageIndex];
    
}

-(void)updateTitleForIndex:(NSInteger)pageIndex{
    self.navigationItem.title = [NSString stringWithFormat:@"%@ von %@",@(pageIndex+1),@(self.galleryItems.count)];
}


-(void)pageViewController:(UIPageViewController *)pageViewController
       didFinishAnimating:(BOOL)finished
  previousViewControllers:(NSArray *)previousViewControllers
      transitionCompleted:(BOOL)completed{
    

    
    self.pageIndex = [[pageViewController.viewControllers firstObject] pageIndex];
    if (completed) {
        [self changeToPlayButton];
    }
    if (finished) {
        for (ImageViewController *ivC in previousViewControllers) {
            [self removeVideoPlayerForVC:ivC];
        }
    }
}

-(void)removeVideoPlayerForVC:(ImageViewController*)vc{
    if (vc.pageIndex != self.pageIndex) {
        if ([vc valueForKey:@"moviePlayer"]) {
            if (vc.item.galleryType == MHGalleryTypeVideo) {
                [vc removeAllMoviePlayerViewsAndNotifications];
            }
        }
    }
}

-(void)updateToolBarForItem:(MHGalleryItem*)item{
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    if (item.galleryType == MHGalleryTypeVideo) {
        [self.tb setItems:@[self.share,flex,self.left,flex,self.playStopButton,flex,self.right,flex]];
    }else{
        [self.tb setItems:@[self.share,flex,self.left,flex,self.right,flex]];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    return [AnimatorShowOverView new];
}

-(void)leftPressed:(id)sender{
    [self.right setEnabled:YES];

    ImageViewController *theCurrentViewController = [self.pvc.viewControllers firstObject];
    NSUInteger indexPage = theCurrentViewController.pageIndex;
    ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage-1]];
    ivC.pageIndex = indexPage-1;
    [ivC setValue:self forKey:@"vc"];

    if (indexPage-1 == 0) {
        [self.left setEnabled:NO];
    }
    __block MHGalleryImageViewerViewController*blockSelf = self;

    [self.pvc setViewControllers:@[ivC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        blockSelf.pageIndex = ivC.pageIndex;
        [blockSelf changeToPlayButton];
    }];
}

-(void)rightPressed:(id)sender{
    [self.left setEnabled:YES];
    ImageViewController *theCurrentViewController = [self.pvc.viewControllers firstObject];
    NSUInteger indexPage = theCurrentViewController.pageIndex;
    ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage+1]];
    ivC.pageIndex = indexPage+1;
    [ivC setValue:self forKey:@"vc"];

    if (indexPage+1 == self.galleryItems.count-1) {
        [self.right setEnabled:NO];
    }
    __block MHGalleryImageViewerViewController*blockSelf = self;
    
    [self.pvc setViewControllers:@[ivC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        blockSelf.pageIndex = ivC.pageIndex;
        [blockSelf changeToPlayButton];
    }];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(ImageViewController *)vc{
    [self.left setEnabled:YES];
    [self.right setEnabled:YES];
    [self removeVideoPlayerForVC:vc];

    NSInteger indexPage = vc.pageIndex;

    if (indexPage ==0) {
        [self.left setEnabled:NO];
        ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:nil];
        ivC.pageIndex = 0;
        [ivC setValue:self forKey:@"vc"];

        return ivC;
    }
    ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage-1]];
    ivC.pageIndex = indexPage-1;
    [ivC setValue:self forKey:@"vc"];

    return ivC;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(ImageViewController *)vc{
    [self.left setEnabled:YES];
    [self.right setEnabled:YES];
    [self removeVideoPlayerForVC:vc];


    NSInteger indexPage = vc.pageIndex;
    
    if (indexPage ==self.galleryItems.count-1) {
        [self.right setEnabled:NO];
        ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:nil];
        ivC.pageIndex = self.galleryItems.count-1;
        [ivC setValue:self forKey:@"vc"];

        return ivC;
    }
    ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:self.galleryItems[indexPage+1]];
    ivC.pageIndex  = indexPage+1;
    [ivC setValue:self forKey:@"vc"];
    return ivC;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    self.tb.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    self.pvc.view.bounds = self.view.bounds;
    [[self.pvc.view.subviews firstObject] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ];

}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{


}

@end

@interface ImageViewController ()
@property(nonatomic,strong)MHGalleryImageViewerViewController *vc;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIButton *moviewPlayerButtonBehinde;
@property (nonatomic, strong) UIToolbar *moviePlayerToolBarTop;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *leftSliderLabel;
@property (nonatomic, strong) UILabel *rightSliderLabel;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSTimer *movieTimer;
@property (nonatomic) NSInteger currentTimeMovie;
@property (nonatomic) NSInteger wholeTimeMovie;
@property (nonatomic) CGPoint   pointToCenterAfterResize;
@property (nonatomic) CGFloat   scaleToRestoreAfterResize;

@end

@implementation ImageViewController


+(ImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item{
    if (item) {
        return [[self alloc]initWithMHMediaItem:item];
    }
    return nil;
}

- (id)initWithMHMediaItem:(MHGalleryItem*)mediaItem
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        
        self.numberFormatter = [NSNumberFormatter new];
        [self.numberFormatter setMinimumIntegerDigits:2];
        
        self.item = mediaItem;
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.delegate = self;
        self.scrollView.tag = 406;
        
        [self.scrollView setMaximumZoomScale:3];
        [self.scrollView setMinimumZoomScale:1];
        [self.scrollView setUserInteractionEnabled:YES];
        [self.view addSubview:self.scrollView];

        
        self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.tag = 506;
        [self.scrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        
        UITapGestureRecognizer *imageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelImageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        
        [self.imageView addGestureRecognizer:doubleTap];
        [self.view addGestureRecognizer:imageTap];
        
        self.act = [[UIActivityIndicatorView alloc]initWithFrame:self.view.bounds];
        [self.act startAnimating];
        [self.act setHidesWhenStopped:YES];
        [self.act setTag:507];
        [self.act setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.scrollView addSubview:self.act];
        
        if (self.item.galleryType != MHGalleryTypeImage) {
            [self addPlayButtonToView];
            
            self.moviePlayerToolBarTop = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 44)];
            [self.moviePlayerToolBarTop setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            self.moviePlayerToolBarTop.alpha =0;
            [self.view addSubview:self.moviePlayerToolBarTop];
            
            self.currentTimeMovie =0;
            self.wholeTimeMovie =0;
            self.slider = [[UISlider alloc]initWithFrame:CGRectMake(55, 0, self.view.frame.size.width-110, 44)];
            [self.slider setMaximumValue:10];
            [self.slider setMinimumValue:0];
            [self.slider setThumbImage:[UIImage imageNamed:@"sliderPoint"] forState:UIControlStateNormal];
            [self.slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
            [self.slider addTarget:self action:@selector(sliderDidDragExit:) forControlEvents:UIControlEventTouchUpInside];
            [self.slider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [self.moviePlayerToolBarTop addSubview:self.slider];
            
            self.leftSliderLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, 40, 43)];
            
            [self.leftSliderLabel setFont:[UIFont systemFontOfSize:14]];
            [self.leftSliderLabel setText:@"00:00"];
            [self.moviePlayerToolBarTop addSubview:self.leftSliderLabel];
            
            self.rightSliderLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            self.rightSliderLabel.frame =CGRectMake(self.vc.view.frame.size.width-50, 0, 50, 43);
            [self.rightSliderLabel setFont:[UIFont systemFontOfSize:14]];
            [self.rightSliderLabel setText:@"-00:00"];
            self.rightSliderLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
            [self.moviePlayerToolBarTop addSubview:self.rightSliderLabel];
        }else{
            [self.imageView setUserInteractionEnabled:YES];
        }
        [imageTap requireGestureRecognizerToFail: doubleTap];

        if (self.item.galleryType == MHGalleryTypeImage) {
            [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.item.urlString]
                                                       options:SDWebImageContinueInBackground
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                         if (!image) {
                                                             [self.scrollView setMaximumZoomScale:1];
                                                             self.imageView.image = [UIImage imageNamed:@"error"];
                                                         }else{
                                                             self.imageView.image = image;
                                                         }
                                                         [(UIActivityIndicatorView*)[self.scrollView viewWithTag:507] stopAnimating];
                                                     }];

        }else{
            [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:self.item.urlString
                                                                       forSize:CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height*2)
                                                                    atDuration:MHImageGenerationStart
                                                                  successBlock:^(UIImage *image,NSUInteger videoDuration) {
                                                                      self.wholeTimeMovie = videoDuration;
                                                                      NSNumber *minutes = @(videoDuration / 60);
                                                                      NSNumber *seconds = @(videoDuration % 60);
                                                                      
                                                                      self.rightSliderLabel.text = [NSString stringWithFormat:@"-%@:%@",
                                                                                                            [self.numberFormatter stringFromNumber:minutes] ,[self.numberFormatter stringFromNumber:seconds]];
                                                                      
                                                                      
                                                                      [self.slider setMaximumValue:videoDuration];
                                                                      [[self.view viewWithTag:508]setHidden:NO];
                                                                      self.imageView.image = image;
                                                                      
                                                                      self.playButton.frame = CGRectMake(self.vc.view.frame.size.width/2-36, self.vc.view.frame.size.height/2-36, 72, 72);
                                                                      [self.playButton setHidden:NO];
                                                                      [(UIActivityIndicatorView*)[self.scrollView viewWithTag:507] stopAnimating];
                                                                      [UIView animateWithDuration:0.3 animations:^{
                                                                          self.moviePlayerToolBarTop.alpha =1;
                                                                      }];
                                                                  }];
        }
           }
    return self;
}
-(void)sliderDidDragExit:(UISlider*)slider{
    
}
-(void)sliderDidChange:(UISlider*)slider{
    if (self.moviePlayer) {
        [self.moviePlayer setCurrentPlaybackTime:slider.value];
        self.currentTimeMovie = slider.value;
        [self updateTimerLabels];
    }
}

-(void)stopMovie{
    [self.movieTimer invalidate];
    self.movieTimer = nil;
    
    self.playingVideo = NO;
    [self.moviePlayer pause];
    [self.view bringSubviewToFront:self.playButton];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];

}
- (void)loadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
    
	if (loadState & MPMovieLoadStateUnknown){
        NSLog(@"1");

	}
	if (loadState & MPMovieLoadStatePlayable){
        [self.view bringSubviewToFront:self.moviePlayer.view];
        [self.imageView setHidden:NO];
        [self.act stopAnimating];
        
        self.moviewPlayerButtonBehinde = [[UIButton alloc]initWithFrame:self.view.bounds];
        [self.moviewPlayerButtonBehinde addTarget:self action:@selector(handelImageTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.moviewPlayerButtonBehinde setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.view addSubview:self.moviewPlayerButtonBehinde];
        [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
        [self.vc changeToPauseButton];
        self.playingVideo =YES;
        
        if (!self.movieTimer) {
            self.movieTimer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(movieTimerChanged:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.movieTimer forMode:NSRunLoopCommonModes];
        }
        
	}
    if (loadState & MPMovieLoadStatePlaythroughOK){
        NSLog(@"3");

	}
	
	if (loadState & MPMovieLoadStateStalled){
        NSLog(@"4");

	}
}

-(void)updateTimerLabels{
    NSNumber *minutesGo = @(self.currentTimeMovie / 60);
    NSNumber *secondsGo = @(self.currentTimeMovie % 60);
    
    self.leftSliderLabel.text = [NSString stringWithFormat:@"%@:%@",
                                  [self.numberFormatter stringFromNumber:minutesGo] ,[self.numberFormatter stringFromNumber:secondsGo]];
    
    NSNumber *minutes = @((self.wholeTimeMovie-self.currentTimeMovie) / 60);
    NSNumber *seconds = @((self.wholeTimeMovie-self.currentTimeMovie) % 60);

    
    self.rightSliderLabel.text = [NSString stringWithFormat:@"-%@:%@",
                                 [self.numberFormatter stringFromNumber:minutes] ,[self.numberFormatter stringFromNumber:seconds]];
    
    
    
}
-(void)movieTimerChanged:(NSTimer*)timer{
    self.currentTimeMovie = self.moviePlayer.currentPlaybackTime;
    [self.slider setValue:self.moviePlayer.currentPlaybackTime animated:NO];
    [self updateTimerLabels];
}

-(void)addPlayButtonToView{
    
    if (self.playButton) {
        [self.playButton removeFromSuperview];
    }
    self.playButton = [[UIButton alloc]initWithFrame:self.vc.view.bounds];
    self.playButton.frame = CGRectMake(self.vc.view.frame.size.width/2-36, self.vc.view.frame.size.height/2-36, 72, 72);
    [self.playButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    [self.playButton setTag:508];
    [self.playButton setHidden:YES];
    [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
}

-(void)removeAllMoviePlayerViewsAndNotifications{
    
    self.currentTimeMovie =0;
    [self.movieTimer invalidate];
    self.movieTimer = nil;

    
    self.playingVideo =NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayer];
    
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [self addPlayButtonToView];
    [self.playButton setHidden:NO];
    self.playButton.frame = CGRectMake(self.vc.view.frame.size.width/2-36, self.vc.view.frame.size.height/2-36, 72, 72);
    [self.moviewPlayerButtonBehinde removeFromSuperview];
    [self.vc changeToPlayButton];
    [self updateTimerLabels];
    [self.slider setValue:0 animated:NO];


}
-(void)moviePlayBackDidFinish:(NSNotification *)notification{
    [self removeAllMoviePlayerViewsAndNotifications];
}

-(void)addMoviePlayerToView{
    self.moviePlayer = [MPMoviePlayerController new];
    if (self.vc.isHiddingToolBarAndNavigationBar) {
        self.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
    }else{
        self.moviePlayer.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self.moviePlayer setContentURL:[NSURL URLWithString:self.item.urlString]];
    [self.moviePlayer prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    if (self.vc.isHiddingToolBarAndNavigationBar) {
        self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    }else{
        self.moviePlayer.view.backgroundColor = [UIColor whiteColor];
    }
    [self.moviePlayer.view setFrame:self.view.bounds];
    [self.moviePlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    
    [self.view addSubview: self.moviePlayer.view];
    
}
-(void)playButtonPressed{
    if (!self.moviePlayer) {
        [self addMoviePlayerToView];

        [self.moviePlayer play];
        [self.imageView setHidden:YES];
        [self.view bringSubviewToFront:self.scrollView];
        [self.act startAnimating];
    }else{
        self.playingVideo = YES;

        [self.moviePlayer play];
        [self.view bringSubviewToFront:self.moviePlayer.view];
        [self.view bringSubviewToFront:self.moviewPlayerButtonBehinde];
        [self.view bringSubviewToFront:self.moviePlayerToolBarTop];

        [self.vc changeToPauseButton];
        if (!self.movieTimer) {
            self.movieTimer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(movieTimerChanged:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.movieTimer forMode:NSRunLoopCommonModes];
        }
       

    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.vc.isHiddingToolBarAndNavigationBar) {
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.act.color = [UIColor whiteColor];
        [self.moviePlayerToolBarTop setAlpha:0];
    }else{
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.act.color = [UIColor blackColor];
    }
    if (self.item.galleryType == MHGalleryTypeVideo) {
        if (self.imageView.image) {
            self.playButton.frame = CGRectMake(self.vc.view.frame.size.width/2-36, self.vc.view.frame.size.height/2-36, 72, 72);
        }
        self.leftSliderLabel.frame = CGRectMake(8, 0, 40, 43);
        self.rightSliderLabel.frame =CGRectMake(self.vc.view.bounds.size.width-50, 0, 50, 43);

        if([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait){
            if (self.view.bounds.size.width < self.view.bounds.size.height) {
                self.rightSliderLabel.frame =CGRectMake(self.view.bounds.size.height-50, 0, 50, 43);
                if (self.imageView.image) {
                    self.playButton.frame = CGRectMake(self.view.bounds.size.height/2-36, self.view.bounds.size.width/2-36, 72, 72);
                }
            }
        }
        self.moviePlayerToolBarTop.frame =CGRectMake(0, self.navigationController.navigationBar.bounds.size.height+20, self.view.frame.size.width, 44);
    }
}

-(UIView*)statusBarObject{
    NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    UIView *statusBar;
    if ([object respondsToSelector:NSSelectorFromString(key)]) {
        statusBar = [object valueForKey:key];
    }
    return statusBar;
}

-(void)handelImageTap:(UIGestureRecognizer *)gestureRecognizer{
    if (!self.vc.isHiddingToolBarAndNavigationBar) {
        [UIView animateWithDuration:0.3 animations:^{
            
            if (self.moviePlayer) {
                self.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
            }
            if (self.moviePlayerToolBarTop) {
                [self.moviePlayerToolBarTop setAlpha:0];
            }
            [self.navigationController.navigationBar setAlpha:0];
            [self.vc.tb setAlpha:0];
            self.scrollView.backgroundColor = [UIColor blackColor];
            self.vc.pvc.view.backgroundColor = [UIColor blackColor];
            
            [self.vc.descriptionView setAlpha:0];
            [self.vc.descriptionViewBackground setAlpha:0];
            [[self statusBarObject] setAlpha:0];
        } completion:^(BOOL finished) {

            self.vc.hiddingToolBarAndNavigationBar = YES;
            [self.navigationController.navigationBar setHidden:YES];
            [self.vc.tb setHidden:YES];
        }];
    }else{
        [self.navigationController.navigationBar setHidden:NO];
        [self.vc.tb setHidden:NO];
        
        [UIView animateWithDuration:0.3 animations:^{
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

            [self.navigationController.navigationBar setAlpha:1];
            [self.vc.tb setAlpha:1];
            self.scrollView.backgroundColor = [UIColor whiteColor];
            self.vc.pvc.view.backgroundColor = [UIColor whiteColor];
            if (self.moviePlayer) {
                self.moviePlayer.backgroundView.backgroundColor = [UIColor whiteColor];
            }
            if (self.moviePlayerToolBarTop) {
                if (self.item.galleryType == MHGalleryTypeVideo) {
                    [self.moviePlayerToolBarTop setAlpha:1];
                }
            }
            [[self statusBarObject] setAlpha:1];
            [self.vc.descriptionView setAlpha:1];
            [self.vc.descriptionViewBackground setAlpha:1];
        } completion:^(BOOL finished) {
            self.vc.hiddingToolBarAndNavigationBar = NO;
        }];
        
    }
}
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.imageView.image isEqual:[UIImage imageNamed:@"error"]]) {
        return;
    }
    float newScale =  [self.scrollView zoomScale] * 1.5;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = [self.scrollView frame].size.height / scale;
    zoomRect.size.width  = [self.scrollView frame].size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [scrollView.subviews firstObject];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void)prepareToResize{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.scrollView.bounds), CGRectGetMidY(self.scrollView.bounds));
    self.pointToCenterAfterResize = [self.scrollView convertPoint:boundsCenter toView:self.imageView];
    self.scaleToRestoreAfterResize = self.scrollView.zoomScale;
}
- (void)recoverFromResizing{
    self.scrollView.zoomScale = MIN(self.scrollView.maximumZoomScale, MAX(self.scrollView.minimumZoomScale, _scaleToRestoreAfterResize));
    CGPoint boundsCenter = [self.scrollView convertPoint:self.pointToCenterAfterResize fromView:self.imageView];
    CGPoint offset = CGPointMake(boundsCenter.x - self.scrollView.bounds.size.width / 2.0,
                                 boundsCenter.y - self.scrollView.bounds.size.height / 2.0);
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    self.scrollView.contentOffset = offset;
}



- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.scrollView.contentSize;
    CGSize boundsSize = self.scrollView.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration{
    
    if (self.moviePlayerToolBarTop) {
        [self.moviePlayerToolBarTop setFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height+20, self.view.frame.size.width,44)];
        [self.leftSliderLabel setFrame:CGRectMake(8, 0, 40, 43)];
        [self.rightSliderLabel setFrame:CGRectMake(self.view.frame.size.width-20, 0, 50, 43)];
    }
    self.playButton.frame = CGRectMake(self.vc.view.frame.size.width/2-36, self.vc.view.frame.size.height/2-36, 72, 72);
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self prepareToResize];
    [self recoverFromResizing];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
 
}
@end

