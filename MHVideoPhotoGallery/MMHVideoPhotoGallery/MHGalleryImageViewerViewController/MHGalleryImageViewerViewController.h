//
//  MHGalleryImageViewerViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryOverViewController.h"
#import "AnimatorShowOverView.h"
#import "MHVideoImageGalleryGlobal.h"

@interface MHGalleryImageViewerViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UINavigationControllerDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong)          UIToolbar *tb;
@property (nonatomic, strong)          UITextView *descriptionView;
@property (nonatomic, strong)          UIToolbar *descriptionViewBackground;
@property (nonatomic)                  NSInteger pageIndex;
@property (nonatomic, strong)          UIPageViewController *pvc;

-(void)playStopButtonPressed;
-(void)changeToPauseButton;
-(void)changeToPlayButton;
@end

@interface ImageViewController : UIViewController<UIScrollViewDelegate>
@property (nonatomic,strong) MHGalleryItem *item;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIActivityIndicatorView *act;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic)        NSInteger pageIndex;
@property (nonatomic,getter = isPlayingVideo)        BOOL playingVideo;
@property (nonatomic,getter = isPausingVideo)        BOOL pausingVideo;

-(void)stopMovie;
-(void)removeAllMoviePlayerViewsAndNotifications;
-(void)playButtonPressed;

+(ImageViewController *)imageViewControllerForMHMediaItem:(MHGalleryItem*)item;
@end