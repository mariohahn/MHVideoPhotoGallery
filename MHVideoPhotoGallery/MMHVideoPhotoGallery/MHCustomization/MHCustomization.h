//
//  MHCustomization.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 04.03.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHTransitionCustomization : NSObject
@property (nonatomic)       BOOL interactiveDismiss;
@property (nonatomic)       BOOL dismissWithScrollGestureOnFirstAndLastImage;
@property (nonatomic)       BOOL fixXValueForDismiss;
@end


@interface MHUICustomization : NSObject
@property (nonatomic,strong) UIColor *barTintColor;
@property (nonatomic)        BOOL showMHShareViewInsteadOfActivityViewController;
@property (nonatomic)        BOOL useCustomBackButtomImageOnImageViewer;

@end
