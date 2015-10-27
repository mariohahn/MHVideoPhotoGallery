//
//  MHScrollViewLabel.h
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 09/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryLabel.h"

@interface MHScrollViewLabel : UIScrollView
@property (nonatomic,strong) MHGalleryLabel *textLabel;

-(void)setHeightConstraint;
@end
