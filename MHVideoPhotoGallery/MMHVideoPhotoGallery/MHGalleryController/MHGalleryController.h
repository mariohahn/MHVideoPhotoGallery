//
//  MHGalleryController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 01.04.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHGallery.h"

@class MHGalleryController;
@class MHOverviewController;
@class MHGalleryImageViewerViewController;
@class MHGalleryItem;
@class MHTransitionDismissMHGallery;
@class MHBarButtonItem;

@protocol MHGalleryDelegate<NSObject>
@optional
-(void)galleryController:(MHGalleryController*)galleryController didShowIndex:(NSInteger)index;
-(BOOL)galleryController:(MHGalleryController*)galleryController shouldHandleURL:(NSURL *)URL;
-(NSArray<MHBarButtonItem *>*)customizeableToolBarItems:(NSArray<MHBarButtonItem *>*)toolBarItems forGalleryItem:(MHGalleryItem*)galleryItem;
@end

@protocol MHGalleryDataSource<NSObject>



@required
/**
 *  @param index which is currently needed
 *
 *  @return MHGalleryItem
 */
- (MHGalleryItem*)itemForIndex:(NSInteger)index;
/**
 *  @param galleryController
 *
 *  @return the number of Items you want to Display
 */
- (NSInteger)numberOfItemsInGallery:(MHGalleryController*)galleryController;
@end

@interface MHGalleryController : UINavigationController <MHGalleryDataSource>

@property (nonatomic,assign) id<MHGalleryDelegate>              galleryDelegate;
@property (nonatomic,assign) id<MHGalleryDataSource>            dataSource;
@property (nonatomic,assign) BOOL                               autoplayVideos; //Default NO
@property (nonatomic,assign) NSInteger                          presentationIndex; //From which index you want to present the Gallery.
@property (nonatomic,strong) UIImageView                        *presentingFromImageView;
@property (nonatomic,strong) MHGalleryImageViewerViewController *imageViewerViewController;
@property (nonatomic,strong) MHOverviewController               *overViewViewController;
@property (nonatomic,strong) NSArray<MHGalleryItem *>           *galleryItems; //You can set an Array of GalleryItems or you can use the dataSource.
@property (nonatomic,strong) MHTransitionCustomization          *transitionCustomization; //Use transitionCustomization to Customize the GalleryControllers transitions
@property (nonatomic,strong) MHUICustomization                  *UICustomization; //Use UICustomization to Customize the GalleryControllers UI
@property (nonatomic,strong) MHTransitionPresentMHGallery       *interactivePresentationTransition;
@property (nonatomic,assign) MHGalleryViewMode                  presentationStyle;
@property (nonatomic,assign) UIStatusBarStyle                   preferredStatusBarStyleMH;

/**
 *  There are 3 types to present MHGallery. 
 *
 *  @param presentationStyle description of all 3 Types:  
 *
 *       MHGalleryViewModeImageViewerNavigationBarHidden: the NaviagtionBar and the Toolbar is hidden you can also set the backgroundcolor for this state in the UICustomization
 *
 *       MHGalleryViewModeImageViewerNavigationBarShown: the NavigationBar and the Toolbar is shown you can also set the backgroundcolor for this state in the UICustomization
 *
 *       MHGalleryViewModeOverView: presents the GalleryOverView.
 *
 *  @return MHGalleryController
 */
- (id)initWithPresentationStyle:(MHGalleryViewMode)presentationStyle;
+(instancetype)galleryWithPresentationStyle:(MHGalleryViewMode)presentationStyle;

@property (nonatomic, copy) void (^finishedCallback)(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode);

@end

@interface UIViewController(MHGalleryViewController)<UIViewControllerTransitioningDelegate>

/**
 *  For presenting MHGalleryController.
 *
 *  @param galleryController your created GalleryController
 *  @param animated          animated or nonanimated
 *  @param completion        complitionBlock
 */
-(void)presentMHGalleryController:(MHGalleryController*)galleryController
                         animated:(BOOL)animated
                       completion:(void (^)(void))completion;
/**
 *  For dismissing MHGalleryController
 *
 *  @param flag             animated
 *  @param dismissImageView if you use Custom transitions set your imageView for the Transition. For example if you use a tableView with imageViews in your cells. If you present MHGallery with an imageView on the first Index and dismiss it on the 4 Index, you have to return the imageView from your cell on the 4 index.
 *  @param completion       complitionBlock
 */
- (void)dismissViewControllerAnimated:(BOOL)animated
                     dismissImageView:(UIImageView*)dismissImageView
                           completion:(void (^)(void))completion;

@end