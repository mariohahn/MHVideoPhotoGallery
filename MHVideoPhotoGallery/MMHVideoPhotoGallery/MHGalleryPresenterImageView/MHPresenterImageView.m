//
//  MHGalleryPresenterImageView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 20.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHPresenterImageView.h"
#import "MHGalleryGlobals.h"

@interface MHPresenterImageView ()
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) CGFloat startScale;
@end


@implementation MHPresenterImageView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initGestureRecognizers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initGestureRecognizers];
    }
    return self;
}

-(void)setInseractiveGalleryPresentionWithItems:(NSArray*)galleryItems
                              currentImageIndex:(NSInteger)currentImageIndex
                          currentViewController:(UIViewController*)viewController
                                 finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image)
                                                 )FinishBlock{
    self.galleryItems = galleryItems;
    self.currentImageIndex = currentImageIndex;
    self.viewController = viewController;
    self.finishedCallback = FinishBlock;
}
-(void)setShoudlUsePanGestureReconizer:(BOOL)shoudlUsePanGestureReconizer{
    for (UIGestureRecognizer *recognizer in  self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    _shoudlUsePanGestureReconizer = shoudlUsePanGestureReconizer;
    [self initGestureRecognizers];
}
-(void)initGestureRecognizers{
    UIPinchGestureRecognizer *pinchToPresent = [[UIPinchGestureRecognizer alloc]initWithTarget:self
                                                                                        action:@selector(presentMHGalleryPinch:)];
    [self addGestureRecognizer:pinchToPresent];
    
    
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self
                                                                                      action:@selector(userDidRoate:)];
    rotate.delegate = self;
    [self addGestureRecognizer:rotate];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnImage)];
    [self addGestureRecognizer:tap];
    
    
    if (self.shoudlUsePanGestureReconizer) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(presentMHGalleryPan:)];
        [self addGestureRecognizer:pan];
    }
    self.userInteractionEnabled =YES;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


-(void)userDidRoate:(UIRotationGestureRecognizer*)recognizer{
    if (self.presenter) {
        CGFloat angle = recognizer.rotation;
        self.presenter.angle = angle;
    }
}

-(void)didTapOnImage{
    [MHGallerySharedManager sharedManager].ivForPresentingAndDismissingMHGallery = self;
    [self.viewController presentMHGalleryWithItems:self.galleryItems
                                          forIndex:self.currentImageIndex
                                    finishCallback:^(UINavigationController *galleryNavMH, NSInteger pageIndex, UIImage *image) {
                                        if (self.finishedCallback) {
                                            self.finishedCallback(galleryNavMH,pageIndex,image);
                                        }
                                    } customAnimationFromImage:YES];
}
-(void)presentMHGallery{
    [MHGallerySharedManager sharedManager].ivForInteractiveTransition = self;
    self.presenter = [MHAnimatorPresentMHGallery new];
    self.presenter.iv = self;
    [self.viewController presentMHGalleryWithItems:self.galleryItems
                                          forIndex:self.currentImageIndex
                                    finishCallback:^(UINavigationController *galleryNavMH, NSInteger pageIndex, UIImage *image) {
                                        [MHGallerySharedManager sharedManager].ivForInteractiveTransition = nil;
                                        if (self.finishedCallback) {
                                            self.finishedCallback(galleryNavMH,pageIndex,image);
                                        }
                                    } customAnimationFromImage:YES];
}

-(void)presentMHGalleryPan:(UIPanGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self presentMHGallery];
        self.lastPoint = [recognizer locationInView:self.viewController.view];
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self.viewController.view];
        self.presenter.changedPoint = CGPointMake(self.lastPoint.x - point.x, self.lastPoint.y - point.y) ;
        [self.presenter updateInteractiveTransition:0.4];
        self.lastPoint = point;
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        [self.presenter finishInteractiveTransition];
        self.presenter = nil;
    }
}

-(void)presentMHGalleryPinch:(UIPinchGestureRecognizer*)recognizer{
    CGFloat scale = recognizer.scale/5;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale>1) {
            [self presentMHGallery];
            self.lastPoint = [recognizer locationInView:self.viewController.view];
            self.startScale = recognizer.scale/8;
        }else{
            [recognizer setCancelsTouchesInView:YES];
        }
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (recognizer.numberOfTouches <2) {
            [recognizer setEnabled:NO];
            [recognizer setEnabled:YES];
        }
        CGPoint point = [recognizer locationInView:self.viewController.view];
        self.presenter.scale = recognizer.scale/8-self.startScale;
        self.presenter.changedPoint = CGPointMake(self.lastPoint.x - point.x, self.lastPoint.y - point.y) ;
        [self.presenter updateInteractiveTransition:scale];
        self.lastPoint = point;
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if ((self.presenter.ivAnimation.frame.size.width > self.viewController.view.frame.size.width)||(self.presenter.ivAnimation.frame.size.height > self.viewController.view.frame.size.height)) {
            [self.presenter finishInteractiveTransition];
        }else {
            [self.presenter cancelInteractiveTransition];
        }
        self.presenter = nil;
    }
    
    
}

@end
