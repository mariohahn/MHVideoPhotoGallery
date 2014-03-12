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

@interface MHUICustomization()
@property(nonatomic,strong)NSMutableDictionary *backgroundColorsForViewModes;
@end
@implementation MHUICustomization

- (instancetype)init{
    self = [super init];
    if (self) {
        self.barButtonsTintColor = nil;
        self.barStyle = UIBarStyleDefault;
        self.barTintColor = nil;
		self.showMHShareViewInsteadOfActivityViewController = YES;
        self.useCustomBackButtomImageOnImageViewer = YES;
        self.showOverView = YES;
        self.backgroundColorsForViewModes = [NSMutableDictionary  dictionaryWithDictionary:@{@"0":[UIColor blackColor],
                                                                                             @"1" :[UIColor whiteColor],
                                                                                             @"2": [UIColor whiteColor]}];
    }
    return self;
}

-(void)setMHGalleryBackgroundColor:(UIColor *)color forViewMode:(MHGalleryViewMode)viewMode{
    [self.backgroundColorsForViewModes setObject:color forKey:[NSString stringWithFormat:@"%@",@(viewMode)]];
}

-(UIColor*)MHGalleryBackgroundColorForViewMode:(MHGalleryViewMode)viewMode{
    return self.backgroundColorsForViewModes[[NSString stringWithFormat:@"%@",@(viewMode)]];
}


@end
