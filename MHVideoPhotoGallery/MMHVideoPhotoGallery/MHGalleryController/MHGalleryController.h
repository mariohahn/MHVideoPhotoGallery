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

@protocol MHGalleryDelegate<NSObject>
@optional
-(void)galleryController:(MHGalleryController*)galleryController didShowIndex:(NSInteger)index;
@end

@protocol MHGalleryDataSource<NSObject>

@required
- (MHGalleryItem*)itemForIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInGallery:(MHGalleryController*)galleryController;
@end

@interface MHGalleryController : UINavigationController<MHGalleryDataSource>

@property (nonatomic,assign) id<MHGalleryDelegate>              galleryDelegate;
@property (nonatomic,assign) id<MHGalleryDataSource>            dataSource;
@property (nonatomic,assign) NSInteger                          presentationIndex;
@property (nonatomic,strong) UIImageView                        *presentingFromImageView;
@property (nonatomic,strong) MHGalleryImageViewerViewController *imageViewerViewController;
@property (nonatomic,strong) MHOverviewController               *overViewViewController;
@property (nonatomic,strong) NSArray                            *galleryItems;
@property (nonatomic,strong) MHTransitionCustomization          *transitionCustomization;
@property (nonatomic,strong) MHUICustomization                  *UICustomization;
@property (nonatomic,strong) MHTransitionPresentMHGallery       *interactivePresentationTransition;
@property (nonatomic,assign) MHGalleryViewMode                  presentationStyle;
@property (nonatomic,assign) UIStatusBarStyle                   preferredStatusBarStyleMH;

- (id)initWithPresentationStyle:(MHGalleryViewMode)presentationStyle;

@property (nonatomic, copy) void (^finishedCallback)(NSUInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode);

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