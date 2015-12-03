//
//  MHGradientView.m
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 02/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import "MHGradientView.h"
#import "MHCustomization.h"

@implementation MHGradientView

-(instancetype)initWithDirection:(MHGradientDirection)direction andCustomization:(MHUICustomization*)customization{
    self =  [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.direction = direction;
        self.customization = customization;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    
    NSMutableArray *gradients = NSMutableArray.new;
    
    for (UIColor *color in [self.customization MHGradientColorsForDirection:self.direction]) {
        [gradients addObject:(id)color.CGColor];
    }
    
    
    CGFloat gradientBlackClearLocations[] = {0, 0.5, 1};
    CGGradientRef glossGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradients, gradientBlackClearLocations);
    
    CGRect currentBounds = self.bounds;
    
    CGContextDrawLinearGradient(currentContext, glossGradient, CGPointMake(CGRectGetWidth(currentBounds)*0.5, CGRectGetHeight(currentBounds)), CGPointMake(CGRectGetWidth(currentBounds)*0.5, 0), 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
