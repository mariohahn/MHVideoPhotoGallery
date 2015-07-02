//
//  MHGalleryImageViewerViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"

@class MHTransitionShowOverView;
@class MHTransitionDismissMHGallery;
@class MHGalleryController;
@class MHImageViewController;

@interface MHPinchGestureRecognizer : UIPinchGestureRecognizer
@property (nonatomic)NSInteger tag;
@end


@interface MHGalleryImageViewerViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UINavigationControllerDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UINavigationBarDelegate>

@property (nonatomic, strong)          NSArray *galleryItems;
@property (nonatomic, strong)          UIToolbar *toolbar;
@property (nonatomic, strong)          UITextView *descriptionView;
@property (nonatomic, strong)          UIToolbar *descriptionViewBackground;
@property (nonatomic)                  NSInteger pageIndex;
@property (nonatomic, strong)          UIPageViewController *pageViewController;
@property (nonatomic, strong)          UIImageView *presentingFromImageView;
@property (nonatomic, strong)          UIImageView *dismissFromImageView;
@property (nonatomic, strong)          MHTransitionPresentMHGallery *interactivePresentationTranstion;
@property (nonatomic, strong)          MHTransitionCustomization *transitionCustomization;
@property (nonatomic,strong)           MHUICustomization *UICustomization;

@property (nonatomic,getter = isUserScrolling)                   BOOL userScrolls;
@property (nonatomic,getter = isHiddingToolBarAndNavigationBar)  BOOL hiddingToolBarAndNavigationBar;

-(MHGalleryController*)galleryViewController;
-(MHImageViewController *)imageViewControllerForIndex:(NSUInteger)index;
-(void)updateToolBarForItem:(MHGalleryItem*)item;

-(void)playStopButtonPressed;
-(void)changeToPauseButton;
-(void)changeToPlayButton;
@end

@interface MHImageViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong)        MHTransitionDismissMHGallery *interactiveTransition;
@property (nonatomic,strong)        MHTransitionShowOverView *interactiveOverView;
@property (nonatomic,strong)        MHGalleryImageViewerViewController *viewController;
@property (nonatomic,strong)        MHGalleryItem *item;
@property (nonatomic,strong)        UIScrollView *scrollView;
@property (nonatomic,strong)        UIButton *playButton;
@property (nonatomic,strong)        UIActivityIndicatorView *act;
@property (nonatomic,strong)        UIImageView *imageView;
@property (nonatomic,strong)        MPMoviePlayerController *moviePlayer;

@property (nonatomic)               NSInteger pageIndex;
@property (nonatomic)               NSInteger currentTimeMovie;

@property (nonatomic,getter = isPlayingVideo)        BOOL playingVideo;
@property (nonatomic,getter = isPausingVideo)        BOOL pausingVideo;
@property (nonatomic)                                BOOL videoWasPlayable;
@property (nonatomic)                                BOOL videoDownloaded;

-(void)changeUIForViewMode:(MHGalleryViewMode)viewMode;
-(void)updateUIForVideoFile;
-(void)stopMovie;
-(void)removeAllMoviePlayerViewsAndNotifications;
-(void)playButtonPressed;
-(void)centerImageView;
-(void)displayFileContents;

- (instancetype)initWithMHMediaItem:(MHGalleryItem*)item
                     viewController:(MHGalleryImageViewerViewController*)viewController;

+(MHImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item
                                           viewController:(MHGalleryImageViewerViewController*)viewController;
@end