//
//  MHGalleryImageViewerViewController.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHGalleryImageViewerViewController.h"
#import "MHOverviewController.h"
#import "MHTransitionShowShareView.h"
#import "MHTransitionShowOverView.h"
#import "MHGallerySharedManagerPrivate.h"

@implementation MHPinchGestureRecognizer
@end

@interface MHGalleryImageViewerViewController()
@property (nonatomic, strong) UIBarButtonItem          *shareBarButton;
@property (nonatomic, strong) UIBarButtonItem          *leftBarButton;
@property (nonatomic, strong) UIBarButtonItem          *rightBarButton;
@property (nonatomic, strong) UIBarButtonItem          *playStopBarButton;
@end

@implementation MHGalleryImageViewerViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    [UIApplication.sharedApplication setStatusBarStyle:self.galleryViewController.preferredStatusBarStyleMH
                                              animated:YES];
    
    if (![self.descriptionViewBackground isDescendantOfView:self.view]) {
        [self.view addSubview:self.descriptionViewBackground];
    }
    if (![self.descriptionView isDescendantOfView:self.view]) {
        [self.view addSubview:self.descriptionView];
    }
    if (![self.toolbar isDescendantOfView:self.view]) {
        [self.view addSubview:self.toolbar];
    }
    [self.pageViewController.view.subviews.firstObject setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return  self.galleryViewController.preferredStatusBarStyleMH;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

-(void)donePressed{
    MHImageViewController *imageViewer = self.pageViewController.viewControllers.firstObject;
    if (imageViewer.moviePlayer) {
        [imageViewer removeAllMoviePlayerViewsAndNotifications];
    }
    MHTransitionDismissMHGallery *dismissTransiton = [MHTransitionDismissMHGallery new];
    dismissTransiton.orientationTransformBeforeDismiss = [(NSNumber *)[self.navigationController.view valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    dismissTransiton.finishButtonAction = YES;
    imageViewer.interactiveTransition = dismissTransiton;
    
    MHGalleryController *galleryViewController = [self galleryViewController];
    if (galleryViewController.finishedCallback) {
        galleryViewController.finishedCallback(self.pageIndex,imageViewer.imageView.image,dismissTransiton,self.viewModeForBarStyle);
    }
}

-(MHGalleryViewMode)viewModeForBarStyle{
    if (self.isHiddingToolBarAndNavigationBar) {
        return MHGalleryViewModeImageViewerNavigationBarHidden;
    }
    return MHGalleryViewModeImageViewerNavigationBarShown;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.UICustomization          = self.galleryViewController.UICustomization;
    self.transitionCustomization  = self.galleryViewController.transitionCustomization;
    
    if (!self.UICustomization.showOverView) {
        self.navigationItem.hidesBackButton = YES;
    }else{
        if (self.galleryViewController.UICustomization.backButtonState == MHBackButtonStateWithoutBackArrow) {
            UIBarButtonItem *backBarButton = [UIBarButtonItem.alloc initWithImage:MHTemplateImage(@"ic_square")
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(backButtonAction)];
            self.navigationItem.hidesBackButton = YES;
            self.navigationItem.leftBarButtonItem = backBarButton;
        }
    }
    
    UIBarButtonItem *doneBarButton =  [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self
                                                                                  action:@selector(donePressed)];
    
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    self.view.backgroundColor = [self.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
    
    
    self.pageViewController = [UIPageViewController.alloc initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                          options:@{ UIPageViewControllerOptionInterPageSpacingKey : @30.f }];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageViewController.automaticallyAdjustsScrollViewInsets =NO;
    
    MHGalleryItem *item = [self itemForIndex:self.pageIndex];
    
    MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:item viewController:self];
    imageViewController.pageIndex = self.pageIndex;
    [self.pageViewController setViewControllers:@[imageViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    [self.view addSubview:self.pageViewController.view];
    
    self.toolbar = [UIToolbar.alloc initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
    if(self.currentOrientation == UIInterfaceOrientationLandscapeLeft || self.currentOrientation == UIInterfaceOrientationLandscapeRight){
        if (self.view.bounds.size.height > self.view.bounds.size.width) {
            self.toolbar.frame = CGRectMake(0, self.view.frame.size.width-44, self.view.frame.size.height, 44);
        }
    }
    
    self.toolbar.tintColor = self.UICustomization.barButtonsTintColor;
    self.toolbar.tag = 307;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    
    self.playStopBarButton = [UIBarButtonItem.alloc initWithImage:MHGalleryImage(@"play")
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(playStopButtonPressed)];
    
    self.leftBarButton = [UIBarButtonItem.alloc initWithImage:MHGalleryImage(@"left_arrow")
                                                        style:UIBarButtonItemStyleBordered
                                                       target:self
                                                       action:@selector(leftPressed:)];
    
    self.rightBarButton = [UIBarButtonItem.alloc initWithImage:MHGalleryImage(@"right_arrow")
                                                         style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(rightPressed:)];
    
    self.shareBarButton = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                      target:self
                                                                      action:@selector(sharePressed)];
    
    if (self.UICustomization.hideShare) {
        
        self.shareBarButton = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                             target:self
                                                                             action:nil];
        self.shareBarButton.width = 30;
    }
    
    [self updateToolBarForItem:item];
    
    self.descriptionViewBackground = [UIToolbar.alloc initWithFrame:CGRectZero];
    self.descriptionView = [UITextView.alloc initWithFrame:CGRectZero];
    self.descriptionView.backgroundColor = [UIColor clearColor];
    self.descriptionView.font = [UIFont systemFontOfSize:15];
    self.descriptionView.text = item.descriptionString;
    self.descriptionView.textColor = [UIColor blackColor];
    self.descriptionView.scrollEnabled = NO;
    self.descriptionView.userInteractionEnabled = NO;
    
    
    self.toolbar.barTintColor = self.UICustomization.barTintColor;
    self.toolbar.barStyle = self.UICustomization.barStyle;
    self.descriptionViewBackground.barTintColor = self.UICustomization.barTintColor;
    self.descriptionViewBackground.barStyle = self.UICustomization.barStyle;
    
    CGSize size = [self.descriptionView sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];
    
    self.descriptionView.frame = CGRectMake(10, self.view.frame.size.height -size.height-44, self.view.frame.size.width-20, size.height);
    if (self.descriptionView.text.length >0) {
        self.descriptionViewBackground.frame = CGRectMake(0, self.view.frame.size.height -size.height-44, self.view.frame.size.width, size.height);
    }else{
        self.descriptionViewBackground.hidden =YES;
    }
    
    [(UIScrollView*)self.pageViewController.view.subviews[0] setDelegate:self];
    [(UIGestureRecognizer*)[[self.pageViewController.view.subviews[0] gestureRecognizers] firstObject] setDelegate:self];
    
    [self updateTitleForIndex:self.pageIndex];
}


-(void)enableOrDisbaleBarbButtons{
    
    self.leftBarButton.enabled  = YES;
    self.rightBarButton.enabled  = YES;
    
    if (self.pageIndex == 0) {
        self.leftBarButton.enabled =NO;
    }
    if(self.pageIndex == self.numberOfGalleryItems-1){
        self.rightBarButton.enabled =NO;
    }
}

-(void)backButtonAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


-(UIInterfaceOrientation)currentOrientation{
    return UIApplication.sharedApplication.statusBarOrientation;
}

-(NSInteger)numberOfGalleryItems{
    return [self.galleryViewController.dataSource numberOfItemsInGallery:self.galleryViewController];
}

-(MHGalleryItem*)itemForIndex:(NSInteger)index{
    return [self.galleryViewController.dataSource itemForIndex:index];
}

-(MHGalleryController*)galleryViewController{
    if ([self.navigationController isKindOfClass:MHGalleryController.class]) {
        return (MHGalleryController*)self.navigationController;
    }
    return nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:UIButton.class]) {
        if (touch.view.tag != 508) {
            return YES;
        }
    }
    return ([touch.view isKindOfClass:UIControl.class] == NO);
}

-(void)changeToPlayButton{
    self.playStopBarButton.image = MHGalleryImage(@"play");
}

-(void)changeToPauseButton{
    self.playStopBarButton.image = MHGalleryImage(@"pause");
}

-(void)playStopButtonPressed{
    for (MHImageViewController *imageViewController in self.pageViewController.viewControllers) {
        if (imageViewController.pageIndex == self.pageIndex) {
            if (imageViewController.isPlayingVideo) {
                [imageViewController stopMovie];
                [self changeToPlayButton];
            }else{
                [imageViewController playButtonPressed];
            }
        }
    }
}

-(void)sharePressed{
    if (self.UICustomization.showMHShareViewInsteadOfActivityViewController) {
        MHShareViewController *share = [MHShareViewController new];
        share.pageIndex = self.pageIndex;
        share.galleryItems = self.galleryItems;
        [self.navigationController pushViewController:share
                                             animated:YES];
    }else{
        UIActivityViewController *act = [UIActivityViewController.alloc initWithActivityItems:@[[(MHImageViewController*)self.pageViewController.viewControllers.firstObject imageView].image] applicationActivities:nil];
        [self presentViewController:act animated:YES completion:nil];
        
        if ([act respondsToSelector:@selector(popoverPresentationController)]) {
            act.popoverPresentationController.barButtonItem = self.shareBarButton;
        }
        
    }
}

-(void)updateDescriptionLabelForIndex:(NSInteger)index{
    if (index < self.numberOfGalleryItems) {
        MHGalleryItem *item = [self itemForIndex:index];
        self.descriptionView.text = item.descriptionString;
        
        if (item.attributedString) {
            self.descriptionView.attributedText = item.attributedString;
        }
        CGSize size = [self.descriptionView sizeThatFits:CGSizeMake(self.view.frame.size.width-20, MAXFLOAT)];
        
        self.descriptionView.frame = CGRectMake(10, self.view.frame.size.height -size.height-44, self.view.frame.size.width-20, size.height);
        if (self.descriptionView.text.length >0) {
            self.descriptionViewBackground.hidden =NO;
            self.descriptionViewBackground.frame = CGRectMake(0, self.view.frame.size.height -size.height-44, self.view.frame.size.width, size.height);
        }else{
            self.descriptionViewBackground.hidden =YES;
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.userScrolls = NO;
    [self updateTitleAndDescriptionForScrollView:scrollView];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.userScrolls = YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateTitleAndDescriptionForScrollView:scrollView];
}

-(void)updateTitleAndDescriptionForScrollView:(UIScrollView*)scrollView{
    NSInteger pageIndex = self.pageIndex;
    if (scrollView.contentOffset.x > (self.view.frame.size.width+self.view.frame.size.width/2)) {
        pageIndex++;
    }
    if (scrollView.contentOffset.x < self.view.frame.size.width/2) {
        pageIndex--;
    }
    [self updateDescriptionLabelForIndex:pageIndex];
    [self updateTitleForIndex:pageIndex];
}

-(void)updateTitleForIndex:(NSInteger)pageIndex{
    NSString *localizedString  = MHGalleryLocalizedString(@"imagedetail.title.current");
    self.navigationItem.title = [NSString stringWithFormat:localizedString,@(pageIndex+1),@(self.numberOfGalleryItems)];
}


-(void)pageViewController:(UIPageViewController *)pageViewController
       didFinishAnimating:(BOOL)finished
  previousViewControllers:(NSArray *)previousViewControllers
      transitionCompleted:(BOOL)completed{
    
    self.pageIndex = [pageViewController.viewControllers.firstObject pageIndex];
    [self showCurrentIndex:self.pageIndex];
    
    if (finished) {
        for (MHImageViewController *imageViewController in previousViewControllers) {
            [self removeVideoPlayerForVC:imageViewController];
        }
    }
    if (completed) {
        [self updateToolBarForItem:[self itemForIndex:self.pageIndex]];
    }
}



-(void)removeVideoPlayerForVC:(MHImageViewController*)vc{
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
    
    UIBarButtonItem *flex = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil];
    
    UIBarButtonItem *fixed = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                         target:self
                                                                         action:nil];
    fixed.width = 30;
    
    [self enableOrDisbaleBarbButtons];
    
    if (item.galleryType == MHGalleryTypeVideo) {
        MHImageViewController *imageViewController = self.pageViewController.viewControllers.firstObject;
        if (imageViewController.isPlayingVideo) {
            [self changeToPauseButton];
        }else{
            [self changeToPlayButton];
        }
        self.toolbar.items = @[self.shareBarButton,flex,self.leftBarButton,flex,self.playStopBarButton,flex,self.rightBarButton,flex,fixed];
    }else{
        self.toolbar.items =@[self.shareBarButton,flex,self.leftBarButton,flex,self.rightBarButton,flex,fixed];
    }
}



- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:MHTransitionShowOverView.class]) {
        MHImageViewController *imageViewController = self.pageViewController.viewControllers.firstObject;
        return imageViewController.interactiveOverView;
    }else {
        return nil;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    MHImageViewController *theCurrentViewController = self.pageViewController.viewControllers.firstObject;
    if (theCurrentViewController.moviePlayer) {
        [theCurrentViewController removeAllMoviePlayerViewsAndNotifications];
    }
    
    if ([toVC isKindOfClass:MHShareViewController.class]) {
        MHTransitionShowShareView *present = MHTransitionShowShareView.new;
        present.present = YES;
        return present;
    }
    if ([toVC isKindOfClass:MHOverviewController.class]) {
        return MHTransitionShowOverView.new;
    }
    return nil;
}

-(void)leftPressed:(id)sender{
    self.rightBarButton.enabled = YES;
    
    MHImageViewController *theCurrentViewController = self.pageViewController.viewControllers.firstObject;
    if (theCurrentViewController.moviePlayer) {
        [theCurrentViewController removeAllMoviePlayerViewsAndNotifications];
    }

    NSUInteger indexPage = theCurrentViewController.pageIndex;
    MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:[self itemForIndex:indexPage-1] viewController:self];
    imageViewController.pageIndex = indexPage-1;
    
    if (indexPage-1 == 0) {
        self.leftBarButton.enabled = NO;
    }
    if (!imageViewController) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self.pageViewController setViewControllers:@[imageViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        weakSelf.pageIndex = imageViewController.pageIndex;
        [weakSelf updateToolBarForItem:[weakSelf itemForIndex:weakSelf.pageIndex]];
        [weakSelf showCurrentIndex:weakSelf.pageIndex];
    }];
}

-(void)rightPressed:(id)sender{
    self.leftBarButton.enabled =YES;
    
    MHImageViewController *theCurrentViewController = self.pageViewController.viewControllers.firstObject;
    if (theCurrentViewController.moviePlayer) {
        [theCurrentViewController removeAllMoviePlayerViewsAndNotifications];
    }

    NSUInteger indexPage = theCurrentViewController.pageIndex;
    MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:[self itemForIndex:indexPage+1] viewController:self];
    imageViewController.pageIndex = indexPage+1;
    
    if (indexPage+1 == self.numberOfGalleryItems-1) {
        self.rightBarButton.enabled = NO;
    }
    if (!imageViewController) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self.pageViewController setViewControllers:@[imageViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        weakSelf.pageIndex = imageViewController.pageIndex;
        [weakSelf updateToolBarForItem:[weakSelf itemForIndex:weakSelf.pageIndex]];
        [weakSelf showCurrentIndex:weakSelf.pageIndex];
    }];
}

-(void)showCurrentIndex:(NSInteger)currentIndex{
    if ([self.galleryViewController.galleryDelegate respondsToSelector:@selector(galleryController:didShowIndex:)]) {
        [self.galleryViewController.galleryDelegate galleryController:self.galleryViewController
                                                         didShowIndex:currentIndex];
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(MHImageViewController *)vc{
    
    NSInteger indexPage = vc.pageIndex;
    
    if (self.numberOfGalleryItems !=1 && self.numberOfGalleryItems-1 != indexPage) {
        self.leftBarButton.enabled =YES;
        self.rightBarButton.enabled =YES;
    }
    
    [self removeVideoPlayerForVC:vc];
    
    if (indexPage ==0) {
        self.leftBarButton.enabled = NO;
        MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:nil viewController:self];
        imageViewController.pageIndex = 0;
        return imageViewController;
    }
    MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:[self itemForIndex:indexPage-1] viewController:self];
    imageViewController.pageIndex = indexPage-1;
    
    return imageViewController;
}

-(MHImageViewController*)imageViewControllerWithItem:(MHGalleryItem*)item pageIndex:(NSInteger)pageIndex{
    MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:[self itemForIndex:pageIndex] viewController:self];
    imageViewController.pageIndex  = pageIndex;
    return imageViewController;
}
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(MHImageViewController *)vc{
    
    
    NSInteger indexPage = vc.pageIndex;
    
    if (self.numberOfGalleryItems !=1 && indexPage !=0) {
        self.leftBarButton.enabled = YES;
        self.rightBarButton.enabled = YES;
    }
    [self removeVideoPlayerForVC:vc];
    
    if (indexPage ==self.numberOfGalleryItems-1) {
        self.rightBarButton.enabled = NO;
        MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:nil viewController:self];
        imageViewController.pageIndex = self.numberOfGalleryItems-1;
        return imageViewController;
    }
    MHImageViewController *imageViewController =[MHImageViewController imageViewControllerForMHMediaItem:[self itemForIndex:indexPage+1] viewController:self];
    imageViewController.pageIndex  = indexPage+1;
    return imageViewController;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    self.toolbar.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    self.pageViewController.view.bounds = self.view.bounds;
    [self.pageViewController.view.subviews.firstObject setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) ];
    
}

@end

@interface MHImageViewController ()
@property (nonatomic, strong) UIButton                 *moviewPlayerButtonBehinde;
@property (nonatomic, strong) UIToolbar                *moviePlayerToolBarTop;
@property (nonatomic, strong) UISlider                 *slider;
@property (nonatomic, strong) UIProgressView           *videoProgressView;
@property (nonatomic, strong) UILabel                  *leftSliderLabel;
@property (nonatomic, strong) UILabel                  *rightSliderLabel;
@property (nonatomic, strong) NSTimer                  *movieTimer;
@property (nonatomic, strong) NSTimer                  *movieDownloadedTimer;
@property (nonatomic, strong) UIPanGestureRecognizer   *pan;
@property (nonatomic, strong) MHPinchGestureRecognizer *pinch;

@property (nonatomic)         NSInteger                wholeTimeMovie;
@property (nonatomic)         CGPoint                  pointToCenterAfterResize;
@property (nonatomic)         CGFloat                  scaleToRestoreAfterResize;
@property (nonatomic)         CGPoint                  startPoint;
@property (nonatomic)         CGPoint                  lastPoint;
@property (nonatomic)         CGPoint                  lastPointPop;
@property (nonatomic)         BOOL                     shouldPlayVideo;

@end

@implementation MHImageViewController


+(MHImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item
                                             viewController:(MHGalleryImageViewerViewController*)viewController{
    if (item) {
        return [self.alloc initWithMHMediaItem:item
                                viewController:viewController];
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

-(void)userDidPinch:(UIPinchGestureRecognizer*)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale <1) {
            self.imageView.frame = self.scrollView.frame;
            
            self.lastPointPop = [recognizer locationInView:self.view];
            self.interactiveOverView = [MHTransitionShowOverView new];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            recognizer.cancelsTouchesInView = YES;
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (recognizer.numberOfTouches <2) {
            recognizer.enabled =NO;
            recognizer.enabled =YES;
        }
        
        CGPoint point = [recognizer locationInView:self.view];
        self.interactiveOverView.scale = recognizer.scale;
        self.interactiveOverView.changedPoint = CGPointMake(self.lastPointPop.x - point.x, self.lastPointPop.y - point.y) ;
        [self.interactiveOverView updateInteractiveTransition:1-recognizer.scale];
        self.lastPointPop = point;
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (recognizer.scale < 0.65) {
            [self.interactiveOverView finishInteractiveTransition];
        }else{
            [self.interactiveOverView cancelInteractiveTransition];
        }
        self.interactiveOverView = nil;
    }
}

-(void)userDidPan:(UIPanGestureRecognizer*)recognizer{
    
    BOOL userScrolls = self.viewController.userScrolls;
    if (self.viewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if (!self.interactiveTransition) {
            if (self.viewController.numberOfGalleryItems ==1) {
                userScrolls = NO;
                self.viewController.userScrolls = NO;
            }else{
                if (self.pageIndex ==0) {
                    if ([recognizer translationInView:self.view].x >=0) {
                        userScrolls =NO;
                        self.viewController.userScrolls = NO;
                    }else{
                        recognizer.cancelsTouchesInView = YES;
                        recognizer.enabled =NO;
                        recognizer.enabled =YES;
                    }
                }
                if ((self.pageIndex == self.viewController.numberOfGalleryItems-1)) {
                    if ([recognizer translationInView:self.view].x <=0) {
                        userScrolls =NO;
                        self.viewController.userScrolls = NO;
                    }else{
                        recognizer.cancelsTouchesInView = YES;
                        recognizer.enabled =NO;
                        recognizer.enabled =YES;
                    }
                }
            }
        }else{
            userScrolls = NO;
        }
    }
    
    if (!userScrolls || recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat progressY = (self.startPoint.y - [recognizer translationInView:self.view].y)/(self.view.frame.size.height/2);
        progressY = [self checkProgressValue:progressY];
        CGFloat progressX = (self.startPoint.x - [recognizer translationInView:self.view].x)/(self.view.frame.size.width/2);
        progressX = [self checkProgressValue:progressX];
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.startPoint = [recognizer translationInView:self.view];
        }else if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (!self.interactiveTransition ) {
                self.startPoint = [recognizer translationInView:self.view];
                self.lastPoint = [recognizer translationInView:self.view];
                self.interactiveTransition = [MHTransitionDismissMHGallery new];
                
                if(UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationLandscapeLeft){
                    self.interactiveTransition.orientationTransformBeforeDismiss = -M_PI/2;
                }else if(UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationLandscapeRight){
                    self.interactiveTransition.orientationTransformBeforeDismiss = M_PI/2;
                }else{
                    self.interactiveTransition.orientationTransformBeforeDismiss = 0;
                }
                self.interactiveTransition.interactive = YES;
                self.interactiveTransition.moviePlayer = self.moviePlayer;
                
                MHGalleryController *galleryViewController = [self.viewController galleryViewController];
                if (galleryViewController.finishedCallback) {
                    galleryViewController.finishedCallback(self.pageIndex,self.imageView.image,self.interactiveTransition,self.viewController.viewModeForBarStyle);
                }
            }else{
                CGPoint currentPoint = [recognizer translationInView:self.view];
                
                if (self.viewController.transitionCustomization.fixXValueForDismiss) {
                    self.interactiveTransition.changedPoint = CGPointMake(self.startPoint.x, self.lastPoint.y-currentPoint.y);
                }else{
                    self.interactiveTransition.changedPoint = CGPointMake(self.lastPoint.x-currentPoint.x, self.lastPoint.y-currentPoint.y);
                }
                progressY = [self checkProgressValue:progressY];
                progressX = [self checkProgressValue:progressX];
                
                if (!self.viewController.transitionCustomization.fixXValueForDismiss) {
                    if (progressX> progressY) {
                        progressY = progressX;
                    }
                }
                
                [self.interactiveTransition updateInteractiveTransition:progressY];
                self.lastPoint = [recognizer translationInView:self.view];
            }
            
        }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            if (self.interactiveTransition) {
                CGFloat velocityY = [recognizer velocityInView:self.view].y;
                if (velocityY <0) {
                    velocityY = -velocityY;
                }
                if (!self.viewController.transitionCustomization.fixXValueForDismiss) {
                    if (progressX> progressY) {
                        progressY = progressX;
                    }
                }
                
                if (progressY > 0.35 || velocityY >700) {
                    MHStatusBar().alpha =1;
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
           viewController:(MHGalleryImageViewerViewController*)viewController{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        __weak typeof(self) weakSelf = self;
        
        
        self.viewController = viewController;
        
        self.view.backgroundColor = [UIColor blackColor];
        
        self.shouldPlayVideo = NO;
        
        self.item = mediaItem;
        
        self.scrollView = [UIScrollView.alloc initWithFrame:self.view.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.scrollView.delegate = self;
        self.scrollView.tag = 406;
        self.scrollView.maximumZoomScale =3;
        self.scrollView.minimumZoomScale= 1;
        self.scrollView.userInteractionEnabled = YES;
        [self.view addSubview:self.scrollView];
        
        
        self.imageView = [UIImageView.alloc initWithFrame:self.view.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.clipsToBounds = YES;
        self.imageView.tag = 506;
        [self.scrollView addSubview:self.imageView];
        
        self.pinch = [MHPinchGestureRecognizer.alloc initWithTarget:self action:@selector(userDidPinch:)];
        self.pinch.delegate = self;
        
        self.pan = [UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(userDidPan:)];
        UITapGestureRecognizer *doubleTap = [UITapGestureRecognizer.alloc initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired =2;
        
        UITapGestureRecognizer *imageTap =[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(handelImageTap:)];
        imageTap.numberOfTapsRequired =1;
        
        [self.imageView addGestureRecognizer:doubleTap];
        
        self.pan.delegate = self;
        
        if(self.viewController.transitionCustomization.interactiveDismiss){
            [self.imageView addGestureRecognizer:self.pan];
            self.pan.maximumNumberOfTouches =1;
            self.pan.delaysTouchesBegan = YES;
        }
        if (self.viewController.UICustomization.showOverView) {
            [self.scrollView addGestureRecognizer:self.pinch];
        }
        
        [self.view addGestureRecognizer:imageTap];
        
        self.act = [UIActivityIndicatorView.alloc initWithFrame:self.view.bounds];
        [self.act startAnimating];
        self.act.hidesWhenStopped =YES;
        self.act.tag =507;
        self.act.autoresizingMask =UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.scrollView addSubview:self.act];
        if (self.item.galleryType != MHGalleryTypeImage) {
            [self addPlayButtonToView];
            
            self.moviePlayerToolBarTop = [UIToolbar.alloc initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.size.height+([UIApplication sharedApplication].statusBarHidden?0:20), self.view.frame.size.width, 44)];
            self.moviePlayerToolBarTop.autoresizingMask =UIViewAutoresizingFlexibleWidth;
            self.moviePlayerToolBarTop.alpha =0;
            self.moviePlayerToolBarTop.barTintColor = self.viewController.UICustomization.barTintColor;
            [self.view addSubview:self.moviePlayerToolBarTop];
            
            self.currentTimeMovie =0;
            self.wholeTimeMovie =0;
            
            self.videoProgressView = [UIProgressView.alloc initWithFrame:CGRectMake(57, 21, self.view.frame.size.width-114, 3)];
            self.videoProgressView.layer.borderWidth =0.5;
            self.videoProgressView.layer.borderColor =[UIColor colorWithWhite:0 alpha:0.3].CGColor;
            self.videoProgressView.trackTintColor =[UIColor clearColor];
            self.videoProgressView.progressTintColor = [self.viewController.UICustomization.videoProgressTintColor colorWithAlphaComponent:0.3f];
            self.videoProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.moviePlayerToolBarTop addSubview:self.videoProgressView];
            
            self.slider = [UISlider.alloc initWithFrame:CGRectMake(55, 0, self.view.frame.size.width-110, 44)];
            self.slider.maximumValue =10;
            self.slider.minimumValue =0;
            self.slider.minimumTrackTintColor = self.viewController.UICustomization.videoProgressTintColor;
            self.slider.maximumTrackTintColor = [self.viewController.UICustomization.videoProgressTintColor colorWithAlphaComponent:0.2f];
            [self.slider setThumbImage:MHGalleryImage(@"sliderPoint") forState:UIControlStateNormal];
            [self.slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
            [self.slider addTarget:self action:@selector(sliderDidDragExit:) forControlEvents:UIControlEventTouchUpInside];
            self.slider.autoresizingMask =UIViewAutoresizingFlexibleWidth;
            [self.moviePlayerToolBarTop addSubview:self.slider];
            
            self.leftSliderLabel = [UILabel.alloc initWithFrame:CGRectMake(8, 0, 40, 43)];
            self.leftSliderLabel.font =[UIFont systemFontOfSize:14];
            self.leftSliderLabel.text = @"00:00";
            self.leftSliderLabel.textColor = self.viewController.UICustomization.videoProgressTintColor;
            [self.moviePlayerToolBarTop addSubview:self.leftSliderLabel];
            
            self.rightSliderLabel = [UILabel.alloc initWithFrame:CGRectZero];
            self.rightSliderLabel.frame = CGRectMake(self.viewController.view.frame.size.width-50, 0, 50, 43);
            self.rightSliderLabel.font = [UIFont systemFontOfSize:14];
            self.rightSliderLabel.text = @"-00:00";
            self.rightSliderLabel.textColor = self.viewController.UICustomization.videoProgressTintColor;
            self.rightSliderLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
            [self.moviePlayerToolBarTop addSubview:self.rightSliderLabel];
            
            self.scrollView.maximumZoomScale = 1;
            self.scrollView.minimumZoomScale =1;
        }
        
        self.imageView.userInteractionEnabled = YES;
        
        [imageTap requireGestureRecognizerToFail: doubleTap];
        
        
        
        if (self.item.galleryType == MHGalleryTypeImage) {
            
            
            [self.imageView setImageForMHGalleryItem:self.item imageType:MHImageTypeFull successBlock:^(UIImage *image, NSError *error) {
                if (!image) {
                    weakSelf.scrollView.maximumZoomScale  =1;
                    [weakSelf changeToErrorImage];
                }
                [weakSelf.act stopAnimating];
            }];
            
        }else{
            [MHGallerySharedManager.sharedManager startDownloadingThumbImage:self.item.URLString
                                                                successBlock:^(UIImage *image,NSUInteger videoDuration,NSError *error) {
                                                                    if (!error) {
                                                                        [weakSelf handleGeneratedThumb:image
                                                                                         videoDuration:videoDuration
                                                                                             urlString:self.item.URLString];
                                                                    }else{
                                                                        [weakSelf changeToErrorImage];
                                                                    }
                                                                    [weakSelf.act stopAnimating];
                                                                }];
        }
    }
    
    return self;
}

-(void)setImageForImageViewWithImage:(UIImage*)image error:(NSError*)error{
    if (!image) {
        self.scrollView.maximumZoomScale  =1;
        [self changeToErrorImage];
    }else{
        self.imageView.image = image;
    }
    [self.act stopAnimating];
}

-(void)changeToErrorImage{
    self.imageView.image = MHGalleryImage(@"error");
}

-(void)changePlayButtonToUnPlay{
    [self.playButton setImage:MHGalleryImage(@"unplay")
                     forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    
    if (self.item.galleryType == MHGalleryTypeVideo) {
        if (self.moviePlayer) {
            [weakSelf autoPlayVideo];
            return;
        }
        [[MHGallerySharedManager sharedManager] getURLForMediaPlayer:self.item.URLString successBlock:^(NSURL *URL, NSError *error) {
            if (error || URL == nil) {
                [weakSelf changePlayButtonToUnPlay];
            }else{
                [weakSelf addMoviePlayerToViewWithURL:URL];
                [weakSelf autoPlayVideo];
            }
        }];
    }
    
}

-(void)autoPlayVideo{
    if (self.viewController.galleryViewController.autoplayVideos){
        [self playButtonPressed];
    }
}


-(void)handleGeneratedThumb:(UIImage*)image
              videoDuration:(NSInteger)videoDuration
                  urlString:(NSString*)urlString{
    
    self.wholeTimeMovie = videoDuration;
    self.rightSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:videoDuration addMinus:YES];
    
    self.slider.maximumValue = videoDuration;
    [self.view viewWithTag:508].hidden =NO;
    self.imageView.image = image;
    
    self.playButton.frame = CGRectMake(self.viewController.view.frame.size.width/2-36, self.viewController.view.frame.size.height/2-36, 72, 72);
    self.playButton.hidden = NO;
    [self.act stopAnimating];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (self.interactiveOverView) {
        if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
            return YES;
        }
        return NO;
    }
    if (self.interactiveTransition) {
        if ([gestureRecognizer isEqual:self.pan]) {
            return YES;
        }
        return NO;
    }
    if (self.viewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if ((self.pageIndex ==0 || self.pageIndex == self.viewController.numberOfGalleryItems -1)) {
            if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")] ) {
                return YES;
            }
        }
    }
    return NO;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if (self.interactiveOverView) {
        if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
            if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class] && self.scrollView.zoomScale ==1) {
                return YES;
            }else{
                return NO;
            }
        }
    }
    if (self.viewController.isUserScrolling) {
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
    if (self.viewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if ((self.pageIndex ==0 || self.pageIndex == self.viewController.numberOfGalleryItems -1) && [gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
            return YES;
        }
    }
    
    return YES;
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if (self.interactiveOverView || self.interactiveTransition) {
        return NO;
    }
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")]|| [otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] ) {
        return YES;
    }
    if ([gestureRecognizer isKindOfClass:MHPinchGestureRecognizer.class]) {
        return YES;
    }
    if (self.viewController.transitionCustomization.dismissWithScrollGestureOnFirstAndLastImage) {
        if ((self.pageIndex ==0 || self.pageIndex == self.viewController.numberOfGalleryItems -1) && [gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
            return YES;
        }
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
        self.moviePlayer.currentPlaybackTime = slider.value;
        self.currentTimeMovie = slider.value;
        [self updateTimerLabels];
    }
}

-(void)stopMovie{
    
    self.shouldPlayVideo = NO;
    
    [self stopTimer];
    
    self.playingVideo = NO;
    [self.moviePlayer pause];
    
    [self.view bringSubviewToFront:self.playButton];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
    [self.viewController changeToPlayButton];
}

-(void)changeToPlayable{
    self.videoWasPlayable = YES;
    if(!self.viewController.isHiddingToolBarAndNavigationBar){
        self.moviePlayerToolBarTop.alpha =1;
    }
    
    self.moviePlayer.view.hidden =NO;
    [self.view bringSubviewToFront:self.moviePlayer.view];
    
    self.moviewPlayerButtonBehinde = [UIButton.alloc initWithFrame:self.view.bounds];
    [self.moviewPlayerButtonBehinde addTarget:self action:@selector(handelImageTap:) forControlEvents:UIControlEventTouchUpInside];
    self.moviewPlayerButtonBehinde.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view bringSubviewToFront:self.scrollView];
    [self.view addSubview:self.moviewPlayerButtonBehinde];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
    [self.view bringSubviewToFront:self.playButton];
    
    if(self.viewController.transitionCustomization.interactiveDismiss){
        [self.moviewPlayerButtonBehinde addGestureRecognizer:self.pan];
    }
    
    if(self.playingVideo){
        [self bringMoviePlayerToFront];
    }
    if (self.shouldPlayVideo) {
        self.shouldPlayVideo = NO;
        if (self.pageIndex == self.viewController.pageIndex) {
            [self playButtonPressed];
        }
    }
}

- (void)loadStateDidChange:(NSNotification *)notification{
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
    
    if (self.currentTimeMovie <=0) {
        self.leftSliderLabel.text =@"00:00";
        
        self.rightSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:self.wholeTimeMovie addMinus:YES];
    }else{
        self.leftSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:self.currentTimeMovie addMinus:NO];
        self.rightSliderLabel.text = [MHGallerySharedManager stringForMinutesAndSeconds:self.wholeTimeMovie-self.currentTimeMovie addMinus:YES];
    }
}



-(void)changeProgressBehinde:(NSTimer*)timer{
    if (self.moviePlayer.playableDuration !=0) {
        [self.videoProgressView setProgress:self.moviePlayer.playableDuration/self.moviePlayer.duration];
        if ((self.moviePlayer.playableDuration == self.moviePlayer.duration)&& (self.moviePlayer.duration !=0)) {
            [self stopMovieDownloadTimer];
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
    self.playButton = [UIButton.alloc initWithFrame:self.viewController.view.bounds];
    self.playButton.frame = CGRectMake(self.viewController.view.frame.size.width/2-36, self.viewController.view.frame.size.height/2-36, 72, 72);
    [self.playButton setImage:MHGalleryImage(@"playButton") forState:UIControlStateNormal];
    self.playButton.tag =508;
    self.playButton.hidden =YES;
    [self.playButton addTarget:self action:@selector(playButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
}
-(void)stopMovieDownloadTimer{
    [self.movieDownloadedTimer invalidate];
    self.movieDownloadedTimer = nil;
}

-(void)removeAllMoviePlayerViewsAndNotifications{
    
    self.videoDownloaded = NO;
    self.currentTimeMovie =0;
    [self stopTimer];
    [self stopMovieDownloadTimer];
    
    
    self.playingVideo =NO;
    
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:MPMoviePlayerLoadStateDidChangeNotification
                                                object:self.moviePlayer];
    
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:MPMoviePlayerPlaybackDidFinishNotification
                                                object:self.moviePlayer];
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                object:self.moviePlayer];
    
    
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
    
    [self addPlayButtonToView];
    self.playButton.hidden =NO;
    self.playButton.frame = CGRectMake(self.viewController.view.frame.size.width/2-36, self.viewController.view.frame.size.height/2-36, 72, 72);
    [self.moviewPlayerButtonBehinde removeFromSuperview];
    [self.viewController changeToPlayButton];
    [self updateTimerLabels];
    [self.slider setValue:0 animated:NO];
}


-(void)moviePlayBackDidFinish:(NSNotification *)notification{
    self.playingVideo = NO;
    [self.viewController changeToPlayButton];
    self.playButton.hidden =NO;
    [self.view bringSubviewToFront:self.playButton];
    [self stopTimer];
    
    self.moviePlayer.currentPlaybackTime =0;
    [self movieTimerChanged:nil];
    [self updateTimerLabels];
    
}
-(void)stopTimer{
    [self.movieTimer invalidate];
    self.movieTimer = nil;
}

-(void)addMoviePlayerToViewWithURL:(NSURL*)URL{
    
    self.videoWasPlayable = NO;
    
    self.moviePlayer = MPMoviePlayerController.new;
    self.moviePlayer.backgroundView.backgroundColor = [self.viewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    self.moviePlayer.view.backgroundColor = [self.viewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.contentURL = URL;
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(loadStateDidChange:)
                                               name:MPMoviePlayerLoadStateDidChangeNotification
                                             object:self.moviePlayer];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(moviePlayBackDidFinish:)
                                               name:MPMoviePlayerPlaybackDidFinishNotification
                                             object:self.moviePlayer];
    
    self.moviePlayer.shouldAutoplay = NO;
    self.moviePlayer.view.frame = self.view.bounds;
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.moviePlayer.view.hidden = YES;
    
    [self.view addSubview:self.moviePlayer.view];
    
    self.playingVideo =NO;
    
    self.movieDownloadedTimer = [NSTimer timerWithTimeInterval:0.06f
                                                        target:self
                                                      selector:@selector(changeProgressBehinde:)
                                                      userInfo:nil
                                                       repeats:YES];
    
    [NSRunLoop.currentRunLoop addTimer:self.movieDownloadedTimer forMode:NSRunLoopCommonModes];
    
    [self changeToPlayable];
}

-(void)bringMoviePlayerToFront{
    [self.view bringSubviewToFront:self.moviePlayer.view];
    [self.view bringSubviewToFront:self.moviewPlayerButtonBehinde];
    [self.view bringSubviewToFront:self.moviePlayerToolBarTop];
}

-(void)playButtonPressed{
    if (!self.playingVideo) {
        
        [self bringMoviePlayerToFront];
        
        self.playButton.hidden = YES;
        self.playingVideo =YES;
        
        if (self.moviePlayer) {
            [self.moviePlayer play];
            [self.viewController changeToPauseButton];
            
        }else{
            UIActivityIndicatorView *act = [UIActivityIndicatorView.alloc initWithFrame:self.view.bounds];
            act.tag = 304;
            [self.view addSubview:act];
            [act startAnimating];
            self.shouldPlayVideo = YES;
        }
        if (!self.movieTimer) {
            self.movieTimer = [NSTimer timerWithTimeInterval:0.01f
                                                      target:self
                                                    selector:@selector(movieTimerChanged:)
                                                    userInfo:nil
                                                     repeats:YES];
            [NSRunLoop.currentRunLoop addTimer:self.movieTimer forMode:NSRunLoopCommonModes];
        }
        
    }else{
        [self stopMovie];
    }
}

-(MHGalleryViewMode)currentViewMode{
    if (self.viewController.isHiddingToolBarAndNavigationBar) {
        return MHGalleryViewModeImageViewerNavigationBarHidden;
    }
    return MHGalleryViewModeImageViewerNavigationBarShown;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.moviePlayer.backgroundView.backgroundColor = [self.viewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    self.scrollView.backgroundColor = [self.viewController.UICustomization MHGalleryBackgroundColorForViewMode:[self currentViewMode]];
    
    if (self.viewController.isHiddingToolBarAndNavigationBar) {
        self.act.color = [UIColor whiteColor];
        self.moviePlayerToolBarTop.alpha =0;
    }else{
        if (self.moviePlayerToolBarTop) {
            if (self.item.galleryType == MHGalleryTypeVideo) {
                if (self.videoWasPlayable && self.wholeTimeMovie >0) {
                    self.moviePlayerToolBarTop.alpha =1;
                }
            }
        }
        self.act.color = [UIColor blackColor];
    }
    if (self.item.galleryType == MHGalleryTypeVideo) {
        
        if (self.moviePlayer) {
            [self.slider setValue:self.moviePlayer.currentPlaybackTime animated:NO];
        }
        
        if (self.imageView.image) {
            self.playButton.frame = CGRectMake(self.viewController.view.frame.size.width/2-36, self.viewController.view.frame.size.height/2-36, 72, 72);
        }
        self.leftSliderLabel.frame = CGRectMake(8, 0, 40, 43);
        self.rightSliderLabel.frame =CGRectMake(self.viewController.view.bounds.size.width-50, 0, 50, 43);
        
        if(UIApplication.sharedApplication.statusBarOrientation != UIInterfaceOrientationPortrait){
            if (self.view.bounds.size.width < self.view.bounds.size.height) {
                self.rightSliderLabel.frame =CGRectMake(self.view.bounds.size.height-50, 0, 50, 43);
                if (self.imageView.image) {
                    self.playButton.frame = CGRectMake(self.view.bounds.size.height/2-36, self.view.bounds.size.width/2-36, 72, 72);
                }
            }
        }
        self.moviePlayerToolBarTop.frame =CGRectMake(0,44+([UIApplication sharedApplication].statusBarHidden?0:20), self.view.frame.size.width, 44);
        if (!MHISIPAD) {
            if (UIApplication.sharedApplication.statusBarOrientation != UIInterfaceOrientationPortrait) {
                self.moviePlayerToolBarTop.frame =CGRectMake(0,32+([UIApplication sharedApplication].statusBarHidden?0:20), self.view.frame.size.width, 44);
            }
        }
        
    }
}

-(void)changeUIForViewMode:(MHGalleryViewMode)viewMode{
    float alpha =0;
    
    if (viewMode == MHGalleryViewModeImageViewerNavigationBarShown) {
        alpha= 1;
    }

    self.moviePlayer.backgroundView.backgroundColor = [self.viewController.UICustomization MHGalleryBackgroundColorForViewMode:viewMode];
    self.scrollView.backgroundColor = [self.viewController.UICustomization MHGalleryBackgroundColorForViewMode:viewMode];
    self.viewController.pageViewController.view.backgroundColor = [self.viewController.UICustomization MHGalleryBackgroundColorForViewMode:viewMode];
    
    self.navigationController.navigationBar.alpha =alpha;
    self.viewController.toolbar.alpha =alpha;
    
    self.viewController.descriptionView.alpha =alpha;
    self.viewController.descriptionViewBackground.alpha =alpha;

    UIInterfaceOrientation currentOrientation = UIApplication.sharedApplication.statusBarOrientation;
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(currentOrientation);
    BOOL isPhone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;

    if (MHGalleryOSVersion >= 8.0 && isLandscape && isPhone) {
        alpha = 0;
    }
    MHStatusBar().alpha =alpha;
}

-(void)handelImageTap:(UIGestureRecognizer *)gestureRecognizer{
    if (!self.viewController.isHiddingToolBarAndNavigationBar) {
        if ([gestureRecognizer respondsToSelector:@selector(locationInView:)]) {
            CGPoint tappedLocation = [gestureRecognizer locationInView:self.view];
            if (CGRectContainsPoint(self.moviePlayerToolBarTop.frame, tappedLocation)) {
                return;
            }
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (self.moviePlayerToolBarTop) {
                self.moviePlayerToolBarTop.alpha =0;
            }
            [self changeUIForViewMode:MHGalleryViewModeImageViewerNavigationBarHidden];
        } completion:^(BOOL finished) {
            
            self.viewController.hiddingToolBarAndNavigationBar = YES;
            self.navigationController.navigationBar.hidden  =YES;
            self.viewController.toolbar.hidden =YES;
        }];
    }else{
        self.navigationController.navigationBar.hidden = NO;
        self.viewController.toolbar.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self changeUIForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
            if (self.moviePlayerToolBarTop) {
                if (self.item.galleryType == MHGalleryTypeVideo) {
                    self.moviePlayerToolBarTop.alpha =1;
                }
            }
        } completion:^(BOOL finished) {
            self.viewController.hiddingToolBarAndNavigationBar = NO;
        }];
        
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (([self.imageView.image isEqual:MHGalleryImage(@"error")]) || (self.item.galleryType == MHGalleryTypeVideo)) {
        return;
    }
    
    if (self.scrollView.zoomScale >1) {
        [self.scrollView setZoomScale:1 animated:YES];
        return;
    }
    [self centerImageView];
    
    CGRect zoomRect;
    CGFloat newZoomScale = (self.scrollView.maximumZoomScale);
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    zoomRect.size.height = [self.imageView frame].size.height / newZoomScale;
    zoomRect.size.width  = [self.imageView frame].size.width  / newZoomScale;
    
    touchPoint = [self.scrollView convertPoint:touchPoint fromView:self.imageView];
    
    zoomRect.origin.x    = touchPoint.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = touchPoint.y - ((zoomRect.size.height / 2.0));
    
    [self.scrollView zoomToRect:zoomRect animated:YES];
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [scrollView.subviews firstObject];
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



- (CGPoint)maximumContentOffset{
    CGSize contentSize = self.scrollView.contentSize;
    CGSize boundsSize = self.scrollView.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset{
    return CGPointZero;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration{
    if (self.moviePlayerToolBarTop) {
        self.moviePlayerToolBarTop.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height+([UIApplication sharedApplication].statusBarHidden?0:20), self.view.frame.size.width,44);
        self.leftSliderLabel.frame = CGRectMake(8, 0, 40, 43);
        self.rightSliderLabel.frame = CGRectMake(self.view.frame.size.width-20, 0, 50, 43);
    }
    self.playButton.frame = CGRectMake(self.viewController.view.frame.size.width/2-36, self.viewController.view.frame.size.height/2-36, 72, 72);
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*self.scrollView.zoomScale, self.view.bounds.size.height*self.scrollView.zoomScale);
    self.imageView.frame = CGRectMake(0,0 , self.scrollView.contentSize.width,self.scrollView.contentSize.height);

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self prepareToResize];
    [self recoverFromResizing];
    [self centerImageView];
}

-(void)centerImageView{
    if(self.imageView.image){
        CGRect frame  = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height));
        
        if (self.scrollView.contentSize.width==0 && self.scrollView.contentSize.height==0) {
            frame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size,self.scrollView.bounds);
        }
        
        CGSize boundsSize = self.scrollView.bounds.size;
        
        CGRect frameToCenter = CGRectMake(0,0 , frame.size.width, frame.size.height);
        
        if (frameToCenter.size.width < boundsSize.width){
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        }else{
            frameToCenter.origin.x = 0;
        }if (frameToCenter.size.height < boundsSize.height){
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        }else{
            frameToCenter.origin.y = 0;
        }
        self.imageView.frame = frameToCenter;
    }
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self centerImageView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
@end

