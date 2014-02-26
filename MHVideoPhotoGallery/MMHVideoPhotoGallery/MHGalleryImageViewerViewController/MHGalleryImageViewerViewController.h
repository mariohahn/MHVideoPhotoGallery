//
//  MHGalleryImageViewerViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHAnimatorShowOverView.h"
#import "MHGalleryGlobals.h"
#import "MHShareViewController.h"

@interface MHPinchGestureRecognizer : UIPinchGestureRecognizer
@property (nonatomic)NSInteger tag;
@end

@interface MHGalleryImageViewerViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UINavigationControllerDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UINavigationBarDelegate>

@property (nonatomic, strong)          UIToolbar *tb;
@property (nonatomic, strong)          UITextView *descriptionView;
@property (nonatomic, strong)          UIToolbar *descriptionViewBackground;
@property (nonatomic)                  NSInteger pageIndex;
@property (nonatomic, strong)          UIPageViewController *pvc;

@property (nonatomic,getter = isUserScrolling)                   BOOL userScrolls;
@property (nonatomic,getter = isHiddingToolBarAndNavigationBar)  BOOL hiddingToolBarAndNavigationBar;

@property (nonatomic, copy) void (^finishedCallback)(UINavigationController *galleryNavMH, NSUInteger photoIndex,MHAnimatorDismissMHGallery *interactiveTransition,UIImage *image);

-(void)updateToolBarForItem:(MHGalleryItem*)item;
-(void)playStopButtonPressed;
-(void)changeToPauseButton;
-(void)changeToPlayButton;

@end

@interface ImageViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong)        MHAnimatorDismissMHGallery *interactiveTransition;
@property (nonatomic,strong)        MHAnimatorShowOverView *interactiveOverView;
@property (nonatomic,strong)        MHGalleryImageViewerViewController *vc;
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


-(void)stopMovie;
-(void)removeAllMoviePlayerViewsAndNotifications;
-(void)playButtonPressed;
-(void)centerImageView;

+(ImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item;
@end