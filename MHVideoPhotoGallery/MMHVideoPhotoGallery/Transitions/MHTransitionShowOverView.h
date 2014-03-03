//
//  AnimatorShowOverView.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "MHGallery.h"

@interface MHTransitionShowOverView : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign)    BOOL interactionInProgress;
@property (nonatomic, assign)    CGFloat scale;
@property (nonatomic, assign)    CGPoint changedPoint;
@property (nonatomic, assign)    id <UIViewControllerContextTransitioning> context;

@end