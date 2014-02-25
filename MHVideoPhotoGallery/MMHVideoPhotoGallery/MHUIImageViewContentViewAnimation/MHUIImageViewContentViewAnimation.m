//
//  MHUIImageViewContentViewAnimation.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHUIImageViewContentViewAnimation.h"
#import "MHGalleryGlobals.h"

@interface MHUIImageViewContentViewAnimation ()

@property (nonatomic, readwrite) CGRect newFrameWrapper;
@property (nonatomic, readwrite) CGRect newFrameImg;
@property (nonatomic,strong)     UIImageView *iv;

@end

@implementation MHUIImageViewContentViewAnimation

- (id)init {
    self = [super init];
    if (self) {
        self.iv = [[UIImageView alloc]init];
        self.iv.contentMode = UIViewContentModeCenter;
        [self addSubview:self.iv];
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.iv.contentMode = UIViewContentModeCenter;
        [self addSubview:self.iv];
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)animateToViewMode:(UIViewContentMode)contenMode
                forFrame:(CGRect)frame
            withDuration:(float)duration
              afterDelay:(float)delay
                finished:(void (^)(BOOL finished))finishedBlock{
    [self checkImageViewHasImage];
    
    switch (contenMode) {
        case UIViewContentModeScaleAspectFill:{
            [self initToScaleAspectFillToFrame:frame];
            [UIView animateWithDuration:duration animations:^{
                [self animateToScaleAspectFill];
            } completion:^(BOOL finished) {
                [self animateFinishToScaleAspectFill];
                finishedBlock(YES);
            }];
        }
            break;
        case UIViewContentModeScaleAspectFit:{
            [self initToScaleAspectFitToFrame:frame];
            [UIView animateWithDuration:duration animations:^{
                [self animateToScaleAspectFit];
            } completion:^(BOOL finished) {
                finishedBlock(YES);
                
            }];
        }
            break;
            
        default:
            break;
    }
    
}
-(void)checkImageViewHasImage{
    if (!self.iv.image) {
        UIView *view = [[UIView alloc]initWithFrame:self.iv.frame];
        view.backgroundColor = [UIColor whiteColor];
        self.iv.image = [[MHGallerySharedManager sharedManager] imageByRenderingView:view];
    }
}

- (void)initToScaleAspectFitToFrame:(CGRect)newFrame{
    [self checkImageViewHasImage];
    float ratioImg = (self.iv.image.size.width)/(self.iv.image.size.height);
    
    if ([self choiseFunctionWithRationImg:ratioImg forFrame:self.frame]) {
        self.iv.frame = CGRectMake( - (self.frame.size.height * ratioImg - self.frame.size.width) / 2.0f, 0, self.frame.size.height * ratioImg, self.frame.size.height);
    }else{
        self.iv.frame = CGRectMake(0, - (self.frame.size.width / ratioImg - self.frame.size.height) / 2.0f, self.frame.size.width, self.frame.size.width / ratioImg);
    }
    
    self.iv.contentMode = UIViewContentModeScaleAspectFit;
    self.newFrameImg = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
    self.newFrameWrapper = newFrame;
    
}

- (void)initToScaleAspectFillToFrame:(CGRect)newFrame{
    [self checkImageViewHasImage];
    
    float ratioImg = (self.iv.image.size.width) / (self.iv.image.size.height);
    if ([self choiseFunctionWithRationImg:ratioImg forFrame:newFrame]) {
        self.newFrameImg = CGRectMake( - (newFrame.size.height * ratioImg - newFrame.size.width) / 2.0f, 0, newFrame.size.height * ratioImg, newFrame.size.height);
    }else{
        self.newFrameImg = CGRectMake(0, - (newFrame.size.width / ratioImg - newFrame.size.height) / 2.0f, newFrame.size.width, newFrame.size.width / ratioImg);
    }
    self.newFrameWrapper = newFrame;
    
}
- (void)animateToScaleAspectFit{
    self.iv.frame = _newFrameImg;
    [super setFrame:_newFrameWrapper];
}

- (void)animateToScaleAspectFill{
    self.iv.frame = _newFrameImg;
    [super setFrame:_newFrameWrapper];
}

- (void)animateFinishToScaleAspectFill{
    self.iv.contentMode = UIViewContentModeScaleAspectFill;
    self.iv.frame  = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setImage:(UIImage *)image{
    self.iv.image = image;
}

- (UIImage *)image{
    return self.iv.image;
}

- (void)setContentMode:(UIViewContentMode)contentMode{
    self.iv.contentMode = contentMode;
}

- (UIViewContentMode)contentMode{
    return self.iv.contentMode;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.iv.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (BOOL)choiseFunctionWithRationImg:(float)ratioImg forFrame:(CGRect)newFrame{
    BOOL resultat = NO;
    float ratioSelf = (newFrame.size.width)/(newFrame.size.height);
    if (ratioImg < 1) {
        if (ratioImg > ratioSelf ) resultat = true;
    }else{
        if (ratioImg > ratioSelf ) resultat = true;
    }
    return resultat;
}
@end