//
//  MHCustomization.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 04.03.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHCustomization.h"

@implementation MHTransitionCustomization

- (instancetype)init{
    self = [super init];
    if (self) {
        self.interactiveDismiss = YES;
		self.dismissWithScrollGestureOnFirstAndLastImage = YES;
        self.fixXValueForDismiss = NO;
    }
    return self;
}
@end


@implementation MHUICustomization

- (instancetype)init{
    self = [super init];
    if (self) {
        self.barTintColor = nil;
		self.showMHShareViewInsteadOfActivityViewController = YES;
        self.useCustomBackButtomImageOnImageViewer = YES;
    }
    return self;
}

-(void)setUseCustomBackButtomImageOnImageViewer:(BOOL)useCustomBackButtomImageOnImageViewer{
    _useCustomBackButtomImageOnImageViewer = useCustomBackButtomImageOnImageViewer;
}

@end
