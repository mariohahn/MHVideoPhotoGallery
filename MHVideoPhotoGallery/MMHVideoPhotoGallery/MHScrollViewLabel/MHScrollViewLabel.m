//
//  MHScrollViewLabel.m
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 09/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import "MHScrollViewLabel.h"
#import "Masonry.h"

@implementation MHScrollViewLabel

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        self.textLabel = MHGalleryLabel.new;
        [self addSubview:self.textLabel];
        
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.left.mas_equalTo(self.mas_left);
            make.right.mas_equalTo(self.mas_right);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(self);
        }];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.textLabel.preferredMaxLayoutWidth = self.textLabel.bounds.size.width;
  
    [self setHeightConstraint];
}

-(void)setHeightConstraint{
    CGFloat height = [self.textLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    if (height == self.bounds.size.height) {
        return;
    }    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height < 200  ? height : 200);
    }];
}

@end
