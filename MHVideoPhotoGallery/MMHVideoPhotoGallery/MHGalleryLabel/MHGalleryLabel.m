//
//  MHGalleryLabel.m
//  MHVideoPhotoGallery
//
//  Created by MarioHahn on 02/10/15.
//  Copyright © 2015 Mario Hahn. All rights reserved.
//

#import "MHGalleryLabel.h"
#import "MHGallery.h"

@interface MHGalleryLabel()<UIGestureRecognizerDelegate>

@end

@implementation MHGalleryLabel

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureLabel];
        
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configureLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    if (!self.activeLink) {
        [self tappedLabel];
    }
}

-(void)configureLabel{
    self.enabledTextCheckingTypes = NSTextCheckingTypeLink;
   
    self.wholeText = NO;
    self.userInteractionEnabled = YES;
}
-(void)setUICustomization:(MHUICustomization *)UICustomization{
    _UICustomization = UICustomization;
    
    self.attributedTruncationToken = [UICustomization descriptionTruncationString];
    self.linkAttributes = [UICustomization descriptionLinkAttributes];
    self.activeLinkAttributes = [UICustomization descriptionActiveLinkAttributes];
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

@end
