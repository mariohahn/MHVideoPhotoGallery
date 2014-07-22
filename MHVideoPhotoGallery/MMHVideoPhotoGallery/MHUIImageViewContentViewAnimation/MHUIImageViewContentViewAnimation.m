//
//  MHUIImageViewContentViewAnimation.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 30.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHUIImageViewContentViewAnimation.h"
#import "MHGallery.h"
#import "MHGallerySharedManagerPrivate.h"

@interface MHUIImageViewContentViewAnimation ()

@property (nonatomic,readwrite) CGRect      changedFrameWrapper;
@property (nonatomic,readwrite) CGRect      changedFrameImage;
@property (nonatomic,strong)    UIImageView *imageView;

@end

@implementation MHUIImageViewContentViewAnimation

- (id)init {
    self = [super init];
    if (self) {
        self.imageView = UIImageView.new;
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [UIImageView.alloc initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];
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
                if(finishedBlock){
                    finishedBlock(YES);
                }
            }];
        }
            break;
        case UIViewContentModeScaleAspectFit:{
            [self initToScaleAspectFitToFrame:frame];
            [UIView animateWithDuration:duration animations:^{
                [self animateToScaleAspectFit];
            } completion:^(BOOL finished) {
                if(finishedBlock){
                    finishedBlock(YES);
                }
                    
                
            }];
        }
            break;
            
        default:
            break;
    }
    
}
-(void)checkImageViewHasImage{
    if (!self.imageView.image) {
        UIView *view = [UIView.alloc initWithFrame:self.imageView.frame];
        view.backgroundColor = [UIColor whiteColor];
        self.imageView.image =  MHImageFromView(view);
    }
}

- (void)initToScaleAspectFitToFrame:(CGRect)newFrame{
    [self checkImageViewHasImage];
    float ratioImage = (self.imageView.image.size.width)/(self.imageView.image.size.height);
    
    if ([self choiseFunctionWithRationImg:ratioImage forFrame:self.frame]) {
        self.imageView.frame = CGRectMake( - (self.frame.size.height * ratioImage - self.frame.size.width) / 2.0f, 0, self.frame.size.height * ratioImage, self.frame.size.height);
    }else{
        self.imageView.frame = CGRectMake(0, - (self.frame.size.width / ratioImage - self.frame.size.height) / 2.0f, self.frame.size.width, self.frame.size.width / ratioImage);
    }
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.changedFrameImage = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
    self.changedFrameWrapper = newFrame;
    
}

- (void)initToScaleAspectFillToFrame:(CGRect)newFrame{
    [self checkImageViewHasImage];
    
    float ratioImg = (self.imageView.image.size.width) / (self.imageView.image.size.height);
    if ([self choiseFunctionWithRationImg:ratioImg forFrame:newFrame]) {
        self.changedFrameImage = CGRectMake( - (newFrame.size.height * ratioImg - newFrame.size.width) / 2.0f, 0, newFrame.size.height * ratioImg, newFrame.size.height);
    }else{
        self.changedFrameImage = CGRectMake(0, - (newFrame.size.width / ratioImg - newFrame.size.height) / 2.0f, newFrame.size.width, newFrame.size.width / ratioImg);
    }
    self.changedFrameWrapper = newFrame;
    
}
- (void)animateToScaleAspectFit{
    self.imageView.frame = _changedFrameImage;
    [super setFrame:_changedFrameWrapper];
}

- (void)animateToScaleAspectFill{
    self.imageView.frame = _changedFrameImage;
    [super setFrame:_changedFrameWrapper];
}

- (void)animateFinishToScaleAspectFill{
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.frame  = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(UIImage*)imageMH{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}

- (UIImage *)image{
    return nil;
}

- (void)setContentMode:(UIViewContentMode)contentMode{
    self.imageView.contentMode = contentMode;
}

- (UIViewContentMode)contentMode{
    return self.imageView.contentMode;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (BOOL)choiseFunctionWithRationImg:(float)ratioImage forFrame:(CGRect)newFrame{
    BOOL resultat = NO;
    float ratioSelf = (newFrame.size.width)/(newFrame.size.height);
    if (ratioImage < 1) {
        if (ratioImage > ratioSelf ) resultat = true;
    }else{
        if (ratioImage > ratioSelf ) resultat = true;
    }
    return resultat;
}
@end