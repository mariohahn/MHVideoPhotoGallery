//
//  MHGalleryPresenterImageView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 20.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHGalleryPresenterImageView.h"

@implementation MHGalleryPresenterImageView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIPinchGestureRecognizer *pinchToPresent = [[UIPinchGestureRecognizer alloc]initWithTarget:self
                                                                                            action:@selector(presentMHGallery:)];
        [self addGestureRecognizer:pinchToPresent];
    }
    return self;
}
-(void)presentMHGallery:(UIPinchGestureRecognizer*)pinch{
    
    
}

@end
