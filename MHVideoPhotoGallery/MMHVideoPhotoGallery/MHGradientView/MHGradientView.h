//
//  MHGradientView.h
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 02/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHUICustomization;

typedef NS_ENUM(NSUInteger, MHGradientDirection) {
    MHGradientDirectionTopToBottom,
    MHGradientDirectionBottomToTop
};

@interface MHGradientView : UIView

-(instancetype)initWithDirection:(MHGradientDirection)direction
                andCustomization:(MHUICustomization*)customization;

@property (nonatomic) MHGradientDirection direction;
@property (nonatomic,strong) MHUICustomization *customization;
@end
