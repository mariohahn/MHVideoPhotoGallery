//
//  MHGalleryLabel.h
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 02/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#if __has_feature(modules)
@import TTTAttributedLabel;
#else
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#endif
#import "MHCustomization.h"

@class MHGalleryLabel;

@protocol MHGalleryLabelDelegate<NSObject>
@optional
-(void)galleryLabel:(MHGalleryLabel*)label wholeTextDidChange:(BOOL)wholeText;
@end

@interface MHGalleryLabel : TTTAttributedLabel

@property (nonatomic,strong) MHUICustomization *UICustomization;
@property (nonatomic) BOOL wholeText;
@property (nonatomic,assign) id<MHGalleryLabelDelegate>  labelDelegate;
@end
