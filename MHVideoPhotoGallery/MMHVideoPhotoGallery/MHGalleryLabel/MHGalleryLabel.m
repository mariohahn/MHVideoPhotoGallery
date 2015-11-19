//
//  MHGalleryLabel.m
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 02/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import "MHGalleryLabel.h"
#import "MHGallery.h"

@implementation MHGalleryLabel

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureLabel];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureLabel];
    }
    return self;
}

-(void)configureLabel{    
    self.wholeText = NO;
    [self addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(tappedLabel)]];
    self.userInteractionEnabled = YES;
}
-(void)setUICustomization:(MHUICustomization *)UICustomization{
    _UICustomization = UICustomization;
    
    self.attributedTruncationToken = [UICustomization descriptionTruncationString];
}

-(void)tappedLabel{
    self.wholeText = !self.wholeText;
    
    if ([self.labelDelegate respondsToSelector:@selector(galleryLabel:wholeTextDidChange:)]) {
        [self.labelDelegate galleryLabel:self wholeTextDidChange:self.wholeText];
    }
    if ([self.superview isKindOfClass:MHScrollViewLabel.class] && self.wholeText) {
        MHScrollViewLabel *scrollView = (MHScrollViewLabel*)self.superview;
        [scrollView  flashScrollIndicators];
    }
}

-(void)setWholeText:(BOOL)wholeText{
    self.numberOfLines = wholeText ? 0 : 4;
    
    _wholeText = wholeText;
}

- (void) layoutSubviews{
    [super layoutSubviews];
    
    if (self.numberOfLines == 0 ){
        if (self.preferredMaxLayoutWidth != self.frame.size.width){
            self.preferredMaxLayoutWidth = self.frame.size.width;
            [self setNeedsUpdateConstraints];
        }
    }
}
- (CGSize) intrinsicContentSize{
    CGSize s = [super intrinsicContentSize];
    if ( self.numberOfLines == 0 ){
        s.height += 1;
    }
    return s;
}

@end
