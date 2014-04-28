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
        self.useCustomBackButtonImageOnImageViewer = YES;
        self.showOverView = YES;
        self.hideShare = NO;
        self.backButtonState = MHBackButtonStateWithBackArrow;
        self.backgroundColorsForViewModes = [NSMutableDictionary  dictionaryWithDictionary:@{@"0":UIColor.blackColor,
                                                                                             @"1":UIColor.whiteColor,
                                                                                             @"2":UIColor.whiteColor}];
        
        CGSize screenSize = UIScreen.mainScreen.bounds.size;
        UICollectionViewFlowLayout *flowLayoutLanscape = UICollectionViewFlowLayout.new;
        flowLayoutLanscape.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayoutLanscape.sectionInset = UIEdgeInsetsMake(4, 0, 0, 0);
        flowLayoutLanscape.minimumInteritemSpacing = 4;
        flowLayoutLanscape.minimumLineSpacing = 10;
        flowLayoutLanscape.itemSize = CGSizeMake(screenSize.width/3.1, screenSize.width/3.1);
        self.overViewCollectionViewLayoutLandscape = flowLayoutLanscape;
        
        UICollectionViewFlowLayout *flowLayoutPort = UICollectionViewFlowLayout.new;
        flowLayoutPort.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayoutPort.sectionInset = UIEdgeInsetsMake(4, 0, 0, 0);
        flowLayoutPort.minimumInteritemSpacing = 4;
        flowLayoutPort.minimumLineSpacing = 4;
        flowLayoutPort.itemSize = CGSizeMake(screenSize.width/3.1, screenSize.width/3.1);
        self.overViewCollectionViewLayoutPortrait = flowLayoutPort;
        
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
