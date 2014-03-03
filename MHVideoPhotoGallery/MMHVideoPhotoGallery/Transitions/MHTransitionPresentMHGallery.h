//
//  AnimatorShowDetailForPresentingMHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 31.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHUIImageViewContentViewAnimation.h"

@interface MHTransitionPresentMHGallery : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>
@property (nonatomic,strong)    MHUIImageViewContentViewAnimation *transitionImageView;
@property (nonatomic,strong)    UIImageView *presentingImageView;
@property (nonatomic,assign)    CGFloat angle;
@property (nonatomic,assign)    CGFloat scale;
@property (nonatomic,assign)    CGPoint changedPoint;
@property (nonatomic,assign)    id <UIViewControllerContextTransitioning> context;
@property (nonatomic,assign)    BOOL interactive;

@end