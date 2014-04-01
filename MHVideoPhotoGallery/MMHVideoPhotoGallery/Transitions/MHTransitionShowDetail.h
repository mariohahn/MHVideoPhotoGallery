//
//  AnimatorShowDetail.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryImageViewerViewController.h"
#import "MHOverviewController.h"
#import "MHUIImageViewContentViewAnimation.h"

@interface MHTransitionShowDetail : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>
@property (nonatomic,assign)    CGFloat angle;
@property (nonatomic,assign)    CGFloat scale;
@property (nonatomic,assign)    CGPoint changedPoint;
@property (nonatomic,strong)    NSIndexPath *indexPath;
@property (nonatomic,assign)    id <UIViewControllerContextTransitioning> context;
@end