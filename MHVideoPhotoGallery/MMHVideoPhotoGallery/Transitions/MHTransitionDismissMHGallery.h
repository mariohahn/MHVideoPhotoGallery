//
//  AnimatorShowDetailForDismissMHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"
#import "MHUIImageViewContentViewAnimation.h"

@interface MHTransitionDismissMHGallery : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>

@property (nonatomic,strong)    MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong)    UIImageView *transitionImageView;
@property (nonatomic,assign)    CGPoint changedPoint;
@property (nonatomic,assign)    CGFloat orientationTransformBeforeDismiss;
@property (nonatomic,assign)    BOOL interactive;
@property (nonatomic,assign)    BOOL finishButtonAction;

@property (nonatomic,assign)    id <UIViewControllerContextTransitioning> context;
@end