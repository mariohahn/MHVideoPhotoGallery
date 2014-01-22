//
//  MHGalleryImageViewerViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//


#import "MHGalleryImageViewerViewController.h"
#import "MHGalleryOverViewController.h"
#import "AnimatorShowShareView.h"

@interface MHGalleryImageViewerViewController()
@property (nonatomic, strong) NSArray *galleryItems;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) UIBarButtonItem *share;
@property (nonatomic, strong) UIBarButtonItem *left;
@property (nonatomic, strong) UIBarButtonItem *right;
@property (nonatomic, strong) UIBarButtonItem *playStopButton;
@property (nonatomic, strong) ImageViewController *ivC;

@end

@implementation MHGalleryImageViewerViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    
    [self.view addSubview:self.descriptionViewBackground];
    [self.view addSubview:self.descriptionView];
    [self.view addSubview:self.tb];
    [[self.pvc.view.subviews firstObject] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return  UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

-(void)donePressed{
    MHGalleryOverViewController *overView  =[self.navigationController.viewControllers firstObject];
    ImageViewController *imageViewer = self.pvc.viewControllers.firstObject;
    
    overView.finishedCallback(self.pageIndex,nil,imageViewer.imageView.image);
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
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight){
        if (self.view.bounds.size.height > self.view.bounds.size.width) {
            self.tb.frame = CGRectMake(0, self.view.frame.size.width-44, self.view.frame.size.height, 44);
        }
    }
    
    self.tb.tag = 307;
    self.tb.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    self.playStopButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Images.bundle/play"] style:UIBarButtonItemStyleBordered target:self action:@selector(playStopButtonPressed)];

    
    self.left = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Images.bundle/left_arrow"] style:UIBarButtonItemStyleBordered target:self action:@selector(leftPressed:)];
    
    self.right = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Images.bundle/right_arrow"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightPressed:)];
    
    self.share = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePressed)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    if (item.galleryType == MHGalleryTypeVideo) {
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
    self.descriptionView = [[UITextView alloc]initWithFrame:CGRectZero];
    self.descriptionView.backgroundColor = [UIColor clearColor];
    self.descriptionView.font = [UIFont systemFontOfSize:15];
    self.descriptionView.text = item.description;
    self.descriptionView.textColor = [UIColor blackColor];
    self.descriptionView.scrollEnabled = NO;
    [self.descriptionView setUserInteractionEnabled:NO];
   
    
    if([MHGallerySharedManager sharedManager].barColor){
        [self.tb setBarTintColor:[MHGallerySharedManager sharedManager].barColor];
        [self.navigationController.navigationBar setBarTintColor:[MHGallerySharedManager sharedManager].barColor];
        [self.descriptionViewBackground setBarTintColor:[MHGallerySharedManager sharedManager].barColor];
    }
    
    CGSize size = [self.descriptionView sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];
    
    self.descriptionView.frame = CGRectMake(10, self.view.frame.size.height -size.height-44, self.view.frame.size.width-20, size.height);
    if (self.descriptionView.text.length >0) {
        self.descriptionViewBackground.frame = CGRectMake(0, self.view.frame.size.height -size.height-44, self.view.frame.size.width, size.height);
    }else{
        [self.descriptionViewBackground setHidden:YES];
    }
    [(UIScrollView*)self.pvc.view.subviews[0] setDelegate:self];
    [(UIGestureRecognizer*)[[self.pvc.view.subviews[0] gestureRecognizers] firstObject] setDelegate:self];
    
    [self updateTitleForIndex:self.pageIndex];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        if (touch.view.tag != 508) {
            return YES;
        }
    }
    return ([touch.view isKindOfClass:[UIControl class]] == NO);
}

-(void)changeToPlayButton{
    [self.playStopButton setImage:[UIImage imageNamed:@"Images.bundle/play"]];
}

-(void)changeToPauseButton{
    [self.playStopButton setImage:[UIImage imageNamed:@"Images.bundle/pause"]];
}

-(void)playStopButtonPressed{
    for (ImageViewController *ivC in self.pvc.viewControllers) {
        if (ivC.pageIndex == self.pageIndex) {
            if (ivC.isPlayingVideo) {
                [ivC stopMovie];
                [self changeToPlayButton];
            }else{
                [ivC playButtonPressed];
            }
        }
    }
}

-(void)sharePressed{
    
    if ([[MHGallerySharedManager sharedManager].viewModes containsObject:MHGalleryViewModeShare]) {
        MHShareViewController *share = [MHShareViewController new];
        share.pageIndex = self.pageIndex;
        [self.navigationController pushViewController:share
                                             animated:YES];
    }else{
        UIActivityViewController *act = [[UIActivityViewController alloc]initWithActivityItems:@[[(ImageViewController*)[self.pvc.viewControllers firstObject] imageView].image] applicationActivities:nil];
        [self presentViewController:act animated:YES completion:nil];
        
    }
}

-(void)updateDescriptionLabelForIndex:(NSInteger)index{
    if (index < self.galleryItems.count) {
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
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.userScrolls = NO;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.userScrolls = YES;
    
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
    
    if (finished) {
        for (ImageViewController *ivC in previousViewControllers) {
            [self removeVideoPlayerForVC:ivC];
            
        }
    }
    if (completed) {
        [self updateToolBarForItem:self.galleryItems[self.pageIndex]];
    }
}

-(void)removeVideoPlayerForVC:(ImageViewController*)vc{
    if (vc.pageIndex != self.pageIndex) {
        if (vc.moviePlayer) {
            if (vc.item.galleryType == MHGalleryTypeVideo) {
                if (vc.isPlayingVideo) {
                    [vc stopMovie];
                }
                vc.currentTimeMovie =0;
            }
        }
    }
}

-(void)updateToolBarForItem:(MHGalleryItem*)item{
    UIBarButtonItem *flex = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    if (item.galleryType == MHGalleryTypeVideo) {
        [self changeToPlayButton];
        [self.tb setItems:@[self.share,flex,self.left,flex,self.playStopButton,flex,self.right,flex]];
    }else{
        [self.tb setItems:@[self.share,flex,self.left,flex,self.right,flex]];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    ImageViewController *theCurrentViewController = [self.pvc.viewControllers firstObject];
    if (theCurrentViewController.moviePlayer) {
        [theCurrentViewController removeAllMoviePlayerViewsAndNotifications];
    }
    
    if ([toVC isKindOfClass:[MHShareViewController class]]) {
        AnimatorShowShareView *present = [AnimatorShowShareView new];
        present.present = YES;
        return present;
    }
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
@property (nonatomic, strong) MHGalleryImageViewerViewController *vc;
@property (nonatomic, strong) UIButton *moviewPlayerButtonBehinde;
@property (nonatomic, strong) UIToolbar *moviePlayerToolBarTop;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIProgressView *progressVideo;
@property (nonatomic, strong) UILabel *leftSliderLabel;
@property (nonatomic, strong) UILabel *rightSliderLabel;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSTimer *movieTimer;
@property (nonatomic, strong) NSTimer *movieDownloadedTimer;

@property (nonatomic) NSInteger wholeTimeMovie;
@property (nonatomic) CGPoint   pointToCenterAfterResize;
@property (nonatomic) CGFloat   scaleToRestoreAfterResize;
@property (nonatomic) CGPoint   startPoint;
@property (nonatomic) CGPoint   lastPoint;

@property (nonatomic)UIPanGestureRecognizer *pan;
@end

@implementation ImageViewController


+(ImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item{
    if (item) {
        return [[self alloc]initWithMHMediaItem:item];
    }
    return nil;
}
-(CGFloat)checkProgressValue:(CGFloat)progress{
    CGFloat progressChecked =progress;
    if (progressChecked <0) {
        progressChecked = -progressChecked;
    }
    if (progressChecked >=1) {
        progressChecked =0.99;
    }
    return progressChecked;
}

-(void)userDidPan:(UIPanGestureRecognizer*)recognizer{
    
    if (!self.vc.userScrolls || recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat progress = (self.startPoint.y - [(UIPanGestureRecognizer*)recognizer translationInView:self.view].y)/220;
        progress = [self checkProgressValue:progress];
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.startPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
        }else if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (!self.interactiveTransition ) {
                self.startPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
                self.lastPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
                
                self.interactiveTransition = [AnimatorShowDetailForDismissMHGallery new];
                
                if ([[MHGallerySharedManager sharedManager].viewModes containsObject:MHGalleryViewModeOverView]) {
                    MHGalleryOverViewController *overView  =[self.navigationController.viewControllers firstObject];
                    overView.finishedCallback(self.pageIndex,self.interactiveTransition,self.imageView.image);
                }else{
                    self.vc.finishedCallback(self.pageIndex,self.interactiveTransition,self.imageView.image);
                }
            }else{
                self.interactiveTransition.changedPoint = self.lastPoint.y - [(UIPanGestureRecognizer*)recognizer translationInView:self.view].y;
                progress = [self checkProgressValue:progress];
                [self.interactiveTransition updateInteractiveTransition:progress];
                self.lastPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
            }
            
        }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            if (self.interactiveTransition) {
                CGFloat velocityY = [recognizer velocityInView:self.view].y;
                if (velocityY <0) {
                    velocityY = -velocityY;
                }
                if (progress > 0.35 || velocityY >700) {
                    [[self statusBarObject] setAlpha:1];
                    [self.interactiveTransition finishInteractiveTransition];
                }else {
                    [self setNeedsStatusBarAppearanceUpdate];
                    [self.interactiveTransition cancelInteractiveTransition];
                }
                self.interactiveTransition = nil;
            }
        }
    }
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
        self.pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(userDidPan:)];
        
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        
        UITapGestureRecognizer *imageTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelImageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        
        [self.imageView addGestureRecognizer:doubleTap];
        
        
        self.pan.delegate = self;
        
        [self.imageView addGestureRecognizer:self.pan];
        
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
            
            self.progressVideo = [[UIProgressView alloc]initWithFrame:CGRectMake(57, 21, self.view.frame.size.width-114, 3)];
            [self.progressVideo.layer setBorderWidth:0.5];
            [self.progressVideo.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.3].CGColor];
            [self.progressVideo setTrackTintColor:[UIColor clearColor]];
            [self.progressVideo setProgressTintColor:[UIColor colorWithWhite:0 alpha:0.3]];
            [self.progressVideo setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            
            [self.moviePlayerToolBarTop addSubview:self.progressVideo];
            
            self.slider = [[UISlider alloc]initWithFrame:CGRectMake(55, 0, self.view.frame.size.width-110, 44)];
            [self.slider setMaximumValue:10];
            
            [self.slider setMinimumValue:0];
            [self.slider setMinimumTrackTintColor:[UIColor blackColor]];
            [self.slider setMaximumTrackTintColor:[UIColor clearColor]];
            [self.slider setThumbImage:[UIImage imageNamed:@"Images.bundle/sliderPoint"] forState:UIControlStateNormal];
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
            
            [self.scrollView setMaximumZoomScale:1];
            [self.scrollView setMinimumZoomScale:1];
        }
        
        [self.imageView setUserInteractionEnabled:YES];
        
        [imageTap requireGestureRecognizerToFail: doubleTap];
        
        if (self.item.galleryType == MHGalleryTypeImage) {
            [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.item.urlString]
                                                       options:SDWebImageContinueInBackground
                                                      progress:nil
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                         if (!image) {
                                                             [self.scrollView setMaximumZoomScale:1];
                                                             self.imageView.image = [UIImage imageNamed:@"Images.bundle/error"];
                                                         }else{
                                                             self.imageView.image = image;
                                                         }
                                                         [(UIActivityIndicatorView*)[self.scrollView viewWithTag:507] stopAnimating];
                                                         
                                                         
                                                     }];
            
        }else{
            
            [[MHGallerySharedManager sharedManager] startDownloadingThumbImage:self.item.urlString
                                                                       forSize:CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height*2)
                                                                    atDuration:MHImageGenerationStart
                                                                  successBlock:^(UIImage *image,NSUInteger videoDuration,NSError *error,NSString *newURL) {
                                                                      if (!error) {
                                                                          [self handleGeneratedThumb:image
                                                                                       videoDuration:videoDuration
                                                                                           urlString:newURL];
                                                                      }else{
                                                                          self.imageView.image = [UIImage imageNamed:@"Images.bundle/error"];
                                                                      }
                                                                  }];
        }
    }
    
    return self;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.moviePlayer && self.item.galleryType == MHGalleryTypeVideo) {
        if ([self.item.urlString rangeOfString:@"vimeo.com"].location != NSNotFound) {
            [[MHGallerySharedManager sharedManager] getVimeoURLforMediaPlayer:self.item.urlString
                                                                 successBlock:^(NSURL *URL, NSError *error) {
                                                                     [self addMoviePlayerToViewWithURL:URL];
            }];
        }else if ([self.item.urlString rangeOfString:@"youtube.com"].location != NSNotFound) {
            [[MHGallerySharedManager sharedManager] getYoutubeURLforMediaPlayer:self.item.urlString
                                                                 successBlock:^(NSURL *URL, NSError *error) {
                                                                     [self addMoviePlayerToViewWithURL:URL];
                                                                 }];
        }else{
            [self addMoviePlayerToViewWithURL:[NSURL  URLWithString:self.item.urlString]];
        }
    }
}

-(void)handleGeneratedThumb:(UIImage*)image
              videoDuration:(NSInteger)videoDuration
                  urlString:(NSString*)urlString{
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
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (self.interactiveTransition) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return YES;
        }
        return NO;
    }
    return NO;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (self.vc.isUserScrolling) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return NO;
        }
    }
    if ([gestureRecognizer isEqual:self.pan] && self.scrollView.zoomScale !=1) {
        return NO;
    }
    if (self.interactiveTransition) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return YES;
        }
        return NO;
    }
    return YES;
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (self.interactiveTransition) {
        return NO;
    }
    
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ) {
        return YES;
    }
    return NO;
}

-(void)sliderDidDragExit:(UISlider*)slider{
    if (self.playingVideo) {
        [self.moviePlayer play];
    }
}
-(void)sliderDidChange:(UISlider*)slider{
    if (self.moviePlayer) {
        [self.moviePlayer pause];
        [self.moviePlayer setCurrentPlaybackTime:slider.value];
        self.currentTimeMovie = slider.value;
        [self updateTimerLabels];
    }
}

-(void)stopMovie{
    [self stopTimer];
    
    self.playingVideo = NO;
    [self.moviePlayer pause];
    
    [self.view bringSubviewToFront:self.playButton];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
    [self.vc changeToPlayButton];
}

-(void)changeToPlayable{
    self.videoWasPlayable = YES;
    if(!self.vc.isHiddingToolBarAndNavigationBar){
            self.moviePlayerToolBarTop.alpha =1;
    }
    
    [self.moviePlayer.view setHidden:NO];
    [self.view bringSubviewToFront:self.moviePlayer.view];
    
    self.moviewPlayerButtonBehinde = [[UIButton alloc]initWithFrame:self.view.bounds];
    [self.moviewPlayerButtonBehinde addTarget:self action:@selector(handelImageTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.moviewPlayerButtonBehinde setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    [self.view bringSubviewToFront:self.scrollView];
    [self.view addSubview:self.moviewPlayerButtonBehinde];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
    [self.view bringSubviewToFront:self.playButton];
    
    [self.moviewPlayerButtonBehinde addGestureRecognizer:self.pan];

    if(self.playingVideo){
        [self.view bringSubviewToFront:self.moviePlayer.view];
        [self.view bringSubviewToFront:self.moviewPlayerButtonBehinde];
        [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
    }
    
    
}

- (void)loadStateDidChange:(NSNotification *)notification
{
	MPMoviePlayerController *player = notification.object;
	MPMovieLoadState loadState = player.loadState;
	if (loadState & MPMovieLoadStatePlayable){
        if (!self.videoWasPlayable) {
            [self performSelectorOnMainThread:@selector(changeToPlayable)
                                   withObject:nil
                                waitUntilDone:YES];
        }
        
	}
    if (loadState & MPMovieLoadStatePlaythroughOK){
        
        self.videoDownloaded = YES;
	}
	
	if (loadState & MPMovieLoadStateStalled){
        
        [self performSelectorOnMainThread:@selector(stopMovie)
                               withObject:nil
                            waitUntilDone:YES];
	}
}

-(void)updateTimerLabels{
    
    if (self.currentTimeMovie && self.wholeTimeMovie) {
        NSNumber *minutesGo = @(self.currentTimeMovie / 60);
        NSNumber *secondsGo = @(self.currentTimeMovie % 60);
        
        self.leftSliderLabel.text = [NSString stringWithFormat:@"%@:%@",
                                     [self.numberFormatter stringFromNumber:minutesGo] ,[self.numberFormatter stringFromNumber:secondsGo]];
        
        NSNumber *minutes = @((self.wholeTimeMovie-self.currentTimeMovie) / 60);
        NSNumber *seconds = @((self.wholeTimeMovie-self.currentTimeMovie) % 60);
        
        
        self.rightSliderLabel.text = [NSString stringWithFormat:@"-%@:%@",
                                      [self.numberFormatter stringFromNumber:minutes] ,[self.numberFormatter stringFromNumber:seconds]];
    }
    
}

-(void)changeProgressBehinde:(NSTimer*)timer{
    if (self.moviePlayer.playableDuration !=0) {
        [self.progressVideo setProgress:self.moviePlayer.playableDuration/self.moviePlayer.duration];
        if ((self.moviePlayer.playableDuration == self.moviePlayer.duration)&& (self.moviePlayer.duration !=0)) {
            [self.movieDownloadedTimer invalidate];
            self.movieDownloadedTimer = nil;
        }
    }
}

-(void)movieTimerChanged:(NSTimer*)timer{
    self.currentTimeMovie = self.moviePlayer.currentPlaybackTime;
    if (!self.slider.isTracking) {
        [self.slider setValue:self.moviePlayer.currentPlaybackTime animated:NO];
    }
    [self updateTimerLabels];
}

-(void)addPlayButtonToView{
    if (self.playButton) {
        [self.playButton removeFromSuperview];
    }
    self.playButton = [[UIButton alloc]initWithFrame:self.vc.view.bounds];
    self.playButton.frame = CGRectMake(self.vc.view.frame.size.width/2-36, self.vc.view.frame.size.height/2-36, 72, 72);
    [self.playButton setImage:[UIImage imageNamed:@"Images.bundle/playButton"] forState:UIControlStateNormal];
    [self.playButton setTag:508];
    [self.playButton setHidden:YES];
    [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
}
-(void)stopMoviePlayerDownloaded{
    
}

-(void)removeAllMoviePlayerViewsAndNotifications{
    
    self.videoDownloaded = NO;
    self.currentTimeMovie =0;
    [self stopTimer];
    [self.movieDownloadedTimer invalidate];
    self.movieDownloadedTimer = nil;
    
    
    self.playingVideo =NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
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
    self.playingVideo = NO;
    [self.vc changeToPlayButton];
    [self.playButton setHidden:NO];
    [self stopTimer];
    
    self.moviePlayer.currentPlaybackTime =0;
    [self movieTimerChanged:nil];
}
-(void)stopTimer{
    [self.movieTimer invalidate];
    self.movieTimer = nil;
}

-(void)addMoviePlayerToViewWithURL:(NSURL*)url{
    self.videoWasPlayable = NO;
    
    self.moviePlayer = [MPMoviePlayerController new];
    if (self.vc.isHiddingToolBarAndNavigationBar) {
        self.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
    }else{
        self.moviePlayer.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self.moviePlayer setContentURL:url];
    
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
    [self.moviePlayer setShouldAutoplay:NO];
    [self.moviePlayer.view setFrame:self.view.bounds];
    [self.moviePlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.moviePlayer.view setHidden:YES];
    
    [self.view addSubview: self.moviePlayer.view];
    self.playingVideo =NO;
    
    self.movieDownloadedTimer = [NSTimer timerWithTimeInterval:0.06f target:self selector:@selector(changeProgressBehinde:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.movieDownloadedTimer forMode:NSRunLoopCommonModes];
    
    [self changeToPlayable];
}


-(void)playButtonPressed{
    if (!self.playingVideo) {
        [self.view bringSubviewToFront:self.moviePlayer.view];
        [self.view bringSubviewToFront:self.moviewPlayerButtonBehinde];
        [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
        
        [self.playButton setHidden:YES];
        self.playingVideo =YES;
        [self.moviePlayer play];
        
        if (!self.movieTimer) {
            self.movieTimer = [NSTimer timerWithTimeInterval:0.01f target:self selector:@selector(movieTimerChanged:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.movieTimer forMode:NSRunLoopCommonModes];
        }
        [self.vc changeToPauseButton];
        
    }else{
        [self stopMovie];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.vc.isHiddingToolBarAndNavigationBar) {
        if (self.moviePlayer) {
            self.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
        }
        if (self.moviePlayerToolBarTop) {
            [self.moviePlayerToolBarTop setAlpha:0];
        }
        
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.act.color = [UIColor whiteColor];
        [self.moviePlayerToolBarTop setAlpha:0];
    }else{
        
        if (self.moviePlayer) {
            self.moviePlayer.backgroundView.backgroundColor = [UIColor whiteColor];
        }
        if (self.moviePlayerToolBarTop) {
            if (self.item.galleryType == MHGalleryTypeVideo) {
                if (self.videoWasPlayable) {
                    [self.moviePlayerToolBarTop setAlpha:1];
                }
            }
        }
        
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.act.color = [UIColor blackColor];
    }
    if (self.item.galleryType == MHGalleryTypeVideo) {
        
        if (self.moviePlayer) {
            [self.slider setValue:self.moviePlayer.currentPlaybackTime animated:NO];
        }
        
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
    if ([self.imageView.image isEqual:[UIImage imageNamed:@"Images.bundle/error"]]) {
        return;
    }
    if (self.item.galleryType == MHGalleryTypeVideo) {
        return;
    }
    if (self.scrollView.zoomScale >1) {
        [self.scrollView setZoomScale:1 animated:YES];
        return;
    }
    CGFloat newZoomScale = (self.scrollView.maximumZoomScale);
    CGFloat xsize = self.scrollView.bounds.size.width / newZoomScale;
    CGFloat ysize = self.scrollView.bounds.size.height / newZoomScale;
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
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
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*self.scrollView.zoomScale, self.view.bounds.size.height*self.scrollView.zoomScale);
    
    self.imageView.frame =CGRectMake(0,0 , self.scrollView.contentSize.width,self.scrollView.contentSize.height);
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self prepareToResize];
    [self recoverFromResizing];
    [self centerImageView];
}

-(void)centerImageView{
    
    CGRect frame  = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
    
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect frameToCenter = CGRectMake(0,0 , frame.size.width, frame.size.height);
    
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
    
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self centerImageView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
@end

